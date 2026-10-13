#!/usr/bin/env python3

import ipaddress
import json
import time
import urllib.request
from pathlib import Path


BASE = Path.home() / "Downloads/999_XXX"
CACHE = BASE / "endpoint_sensor/state/threat_intel_cache.json"
ZEEK_CONN = BASE / "endpoint_sensor/zeek/live/conn.log"

SPAMHAUS_URL = "https://www.spamhaus.org/drop/drop_v4.json"
FEODO_URL = "https://feodotracker.abuse.ch/downloads/ipblocklist_recommended.json"

CACHE_SECONDS = 3600


def fetch_json(url):
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": "999-Cipher-Level6-ThreatIntel/1.0",
            "Accept": "application/json",
        },
    )

    with urllib.request.urlopen(req, timeout=20) as response:
        text = response.read().decode("utf-8")

    if url == SPAMHAUS_URL:
        rows = []

        for line in text.splitlines():
            line = line.strip()

            if not line:
                continue

            try:
                item = json.loads(line)
            except json.JSONDecodeError:
                continue

            if isinstance(item, dict):
                rows.append(item)

        return rows

    return json.loads(text)


def load_cache():
    try:
        data = json.loads(CACHE.read_text())

        if time.time() - data.get("updated_at", 0) < CACHE_SECONDS:
            return data

    except Exception:
        pass

    return None


def parse_spamhaus(data):
    networks = []

    if isinstance(data, list):
        rows = data
    else:
        rows = []

    for row in rows:
        if not isinstance(row, dict):
            continue

        cidr = row.get("cidr")

        if not cidr:
            continue

        try:
            networks.append(str(ipaddress.ip_network(cidr)))
        except ValueError:
            pass

    return networks


def parse_feodo(data):
    ips = {}

    if not isinstance(data, list):
        return ips

    for row in data:
        if not isinstance(row, dict):
            continue

        ip = row.get("ip_address")

        if not ip:
            continue

        try:
            ipaddress.ip_address(ip)
        except ValueError:
            continue

        ips[ip] = {
            "malware": row.get("malware"),
            "status": row.get("status"),
            "port": row.get("port"),
        }

    return ips


def refresh():
    cached = load_cache()

    if cached is not None:
        return cached

    spamhaus = []
    feodo = {}

    errors = []

    try:
        spamhaus = parse_spamhaus(
            fetch_json(SPAMHAUS_URL)
        )
    except Exception as error:
        errors.append(f"Spamhaus: {error}")

    try:
        feodo = parse_feodo(
            fetch_json(FEODO_URL)
        )
    except Exception as error:
        errors.append(f"Feodo: {error}")

    result = {
        "updated_at": time.time(),
        "spamhaus_networks": spamhaus,
        "feodo_ips": feodo,
        "errors": errors,
    }

    CACHE.parent.mkdir(parents=True, exist_ok=True)
    CACHE.write_text(
        json.dumps(result, indent=2, sort_keys=True)
    )

    return result


def zeek_rows():
    if not ZEEK_CONN.exists():
        return []

    fields = None
    rows = []

    try:
        lines = ZEEK_CONN.read_text(
            errors="replace"
        ).splitlines()
    except Exception:
        return []

    for line in lines:
        if line.startswith("#fields\t"):
            fields = line.split("\t")[1:]
            continue

        if (
            not line
            or line.startswith("#")
            or fields is None
        ):
            continue

        values = line.split("\t")

        if len(values) < len(fields):
            values += ["-"] * (
                len(fields) - len(values)
            )

        rows.append(
            dict(zip(fields, values))
        )

    return rows


def run(send_event):
    intel = refresh()

    spamhaus_nets = []

    for cidr in intel.get(
        "spamhaus_networks",
        [],
    ):
        try:
            spamhaus_nets.append(
                ipaddress.ip_network(cidr)
            )
        except ValueError:
            pass

    feodo = intel.get("feodo_ips", {})

    state_path = (
        BASE
        / "endpoint_sensor/state/threat_intel_matches.json"
    )

    try:
        previous = set(
            json.loads(state_path.read_text())
        )
    except Exception:
        previous = set()

    current = set()
    sent = 0

    for row in zeek_rows():
        remote = row.get("id.resp_h")

        if not remote:
            continue

        try:
            addr = ipaddress.ip_address(remote)
        except ValueError:
            continue

        if addr.is_private or addr.is_loopback:
            continue

        if remote in feodo:
            meta = feodo[remote]

            fingerprint = (
                f"FEODO|{remote}|"
                f"{meta.get('port')}|"
                f"{meta.get('malware')}"
            )

            current.add(fingerprint)

            if fingerprint not in previous:
                send_event(
                    "SUSPICIOUS_OUTBOUND_CONNECTION",
                    details=(
                        f"Network connection matched "
                        f"Feodo Tracker botnet C2 intelligence. "
                        f"Destination={remote}; "
                        f"malware={meta.get('malware')}; "
                        f"status={meta.get('status')}; "
                        f"listed_port={meta.get('port')}"
                    ),
                    rule_name=(
                        "Threat intelligence match - "
                        "known botnet C2"
                    ),
                    confidence=98,
                )

                sent += 1

            continue

        for network in spamhaus_nets:
            if addr in network:
                fingerprint = (
                    f"SPAMHAUS_DROP|{remote}|{network}"
                )

                current.add(fingerprint)

                if fingerprint not in previous:
                    send_event(
                        "SUSPICIOUS_OUTBOUND_CONNECTION",
                        details=(
                            f"Network connection matched "
                            f"Spamhaus DROP range. "
                            f"Destination={remote}; "
                            f"network={network}"
                        ),
                        rule_name=(
                            "Threat intelligence match - "
                            "Spamhaus DROP"
                        ),
                        confidence=95,
                    )

                    sent += 1

                break

    state_path.write_text(
        json.dumps(
            sorted(current),
            indent=2,
        )
    )

    return {
        "spamhaus_ranges": len(spamhaus_nets),
        "feodo_ips": len(feodo),
        "matches": len(current),
        "events_sent": sent,
        "feed_errors": intel.get("errors", []),
    }
