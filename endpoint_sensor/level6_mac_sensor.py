#!/usr/bin/env python3

import json
import hashlib
import os
import socket
import subprocess
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from extended_detection_pack import run_extended_checks
from yara.yara_monitor import run as run_yara_monitor
from zeek.zeek_monitor import run as run_zeek_monitor
from threat_intel.threat_intel import run as run_threat_intel

WORKER_URL = "https://999-cipher-level6-collector.jontarius.workers.dev/endpoint/event"
ENDPOINT_ID = "macbook-primary"

ROOT = Path(__file__).resolve().parent
STATE = ROOT / "state"
LOGS = ROOT / "logs"

STATE.mkdir(parents=True, exist_ok=True)
LOGS.mkdir(parents=True, exist_ok=True)

PORT_BASELINE = STATE / "ports.json"
PERSIST_BASELINE = STATE / "persistence.json"

def run(cmd):
    return subprocess.run(
        cmd,
        shell=True,
        text=True,
        capture_output=True,
    ).stdout.strip()

def keychain_secret():
    result = subprocess.run(
        [
            "security",
            "find-generic-password",
            "-a", os.environ.get("USER", ""),
            "-s", "999-cipher-endpoint-sensor",
            "-w",
        ],
        text=True,
        capture_output=True,
    )

    if result.returncode != 0:
        raise RuntimeError("Endpoint sensor credential not found in Keychain")

    return result.stdout.strip()

def send_event(event_type, details=None, **extra):
    payload = {
        "event_type": event_type,
        "occurred_at": datetime.now(timezone.utc).isoformat(),
        "hostname": socket.gethostname(),
        "endpoint_id": ENDPOINT_ID,
        "confidence": 85,
        "action": "OBSERVED",
        "details": details,
        **extra,
    }

    data = json.dumps(payload).encode()

    req = urllib.request.Request(
        WORKER_URL,
        data=data,
        method="POST",
        headers={
            "Authorization": f"Bearer {keychain_secret()}",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "999-Cipher-Level6-Endpoint/1.0",
        },
    )

    with urllib.request.urlopen(req, timeout=15) as response:
        result = response.read().decode()

    if event_type not in {
        "SECURITY_BASELINE_CHANGE",
        "ENDPOINT_OFFLINE",
    }:
        try:
            evaluate_correlation(event_type, details)
        except Exception as error:
            print(f"Correlation warning: {error}")

    return result

def get_ports():
    query = """
    SELECT
      p.name,
      p.path,
      l.address,
      l.port,
      l.protocol
    FROM listening_ports l
    LEFT JOIN processes p ON p.pid = l.pid
    WHERE l.port > 0;
    """

    raw = subprocess.check_output(
        ["/usr/local/bin/osqueryi", "--json", query],
        text=True,
    )

    rows = json.loads(raw)

    normalized = []

    for row in rows:
        normalized.append({
            "name": row.get("name") or "",
            "path": row.get("path") or "",
            "address": row.get("address") or "",
            "port": int(row.get("port") or 0),
            "protocol": str(row.get("protocol") or ""),
        })

    return sorted(
        normalized,
        key=lambda x: (
            x["name"],
            x["address"],
            x["port"],
            x["protocol"],
        ),
    )

def get_persistence():
    locations = [
        Path.home() / "Library/LaunchAgents",
        Path("/Library/LaunchAgents"),
        Path("/Library/LaunchDaemons"),
    ]

    result = []

    for directory in locations:
        if not directory.exists():
            continue

        for item in directory.glob("*.plist"):
            try:
                stat = item.stat()
                result.append({
                    "path": str(item),
                    "size": stat.st_size,
                    "mtime": int(stat.st_mtime),
                })
            except OSError:
                pass

    return sorted(result, key=lambda x: x["path"])

def load(path):
    if not path.exists():
        return None

    return json.loads(path.read_text())

def save(path, value):
    path.write_text(json.dumps(value, indent=2))

def check_security_controls():
    sip = run("csrutil status 2>/dev/null")
    filevault = run("fdesetup status 2>/dev/null")

    if "enabled" not in sip.lower():
        send_event(
            "SIP_DISABLED",
            details=sip,
            rule_name="System Integrity Protection disabled",
        )

    if "filevault is on" not in filevault.lower():
        send_event(
            "FILEVAULT_DISABLED",
            details=filevault,
            rule_name="FileVault disabled",
        )

def check_ports():
    current = get_ports()
    previous = load(PORT_BASELINE)

    if previous is None:
        save(PORT_BASELINE, current)
        return

    old = {
        (x["name"], x["path"], x["address"], x["port"], x["protocol"])
        for x in previous
    }

    new = {
        (x["name"], x["path"], x["address"], x["port"], x["protocol"])
        for x in current
    }

    for item in sorted(new - old):
        name, path, address, port, protocol = item

        send_event(
            "NEW_LISTENING_PORT",
            process_name=name,
            process_path=path,
            port=port,
            protocol=protocol,
            details=f"New listener {address}:{port}",
            rule_name="New listening network service",
        )

    save(PORT_BASELINE, current)

def check_persistence():
    current = get_persistence()
    previous = load(PERSIST_BASELINE)

    if previous is None:
        save(PERSIST_BASELINE, current)
        return

    old = {x["path"]: x for x in previous}
    new = {x["path"]: x for x in current}

    for path, item in new.items():
        if path not in old:
            send_event(
                "NEW_PERSISTENCE_ITEM",
                item_path=path,
                details="New LaunchAgent or LaunchDaemon detected",
            )
        elif (
            item["size"] != old[path]["size"]
            or item["mtime"] != old[path]["mtime"]
        ):
            send_event(
                "PERSISTENCE_ITEM_CHANGED",
                item_path=path,
                previous_value=json.dumps(old[path]),
                current_value=json.dumps(item),
                details="Existing persistence item changed",
            )

    for path in old.keys() - new.keys():
        send_event(
            "PERSISTENCE_ITEM_REMOVED",
            item_path=path,
            details="Previously baselined persistence item removed",
        )

    save(PERSIST_BASELINE, current)


def check_failed_logins():
    cmd = (
        'log show --last 10m --style compact '
        '--predicate \'eventMessage CONTAINS[c] "authentication failed" '
        'OR eventMessage CONTAINS[c] "login failed"\' 2>/dev/null'
    )

    output = run(cmd)

    lines = [
        line for line in output.splitlines()
        if line.strip() and not line.startswith("Timestamp")
    ]

    if len(lines) >= 5:
        send_event(
            "FAILED_LOGIN_BURST",
            details=f"{len(lines)} failed authentication events observed in 10 minutes",
            rule_name="Failed login burst",
            confidence=90,
        )


def check_suspicious_processes():
    query = '''
    SELECT pid, name, path
    FROM processes
    WHERE
      path LIKE '/tmp/%'
      OR path LIKE '/private/tmp/%'
      OR path LIKE '/var/tmp/%';
    '''

    raw = subprocess.check_output(
        ["/usr/local/bin/osqueryi", "--json", query],
        text=True,
    )

    rows = json.loads(raw)

    ignored = {
        "osqueryd",
    }

    for row in rows:
        name = row.get("name") or ""
        path = row.get("path") or ""

        if not path or name in ignored:
            continue

        send_event(
            "SUSPICIOUS_PROCESS",
            process_name=name,
            process_path=path,
            details="Executable observed running from a temporary directory",
            rule_name="Suspicious executable location",
            confidence=75,
        )


def get_admin_members():
    output = run("dscl . -read /Groups/admin GroupMembership 2>/dev/null")

    if not output:
        return []

    parts = output.split()

    if parts and parts[0] == "GroupMembership:":
        parts = parts[1:]

    return sorted(parts)


def check_admin_membership():
    path = STATE / "admins.json"

    current = get_admin_members()
    previous = load(path)

    if previous is None:
        save(path, current)
        return

    if current != previous:
        send_event(
            "PRIVILEGE_CHANGE",
            previous_value=json.dumps(previous),
            current_value=json.dumps(current),
            details="Local administrators group membership changed",
            rule_name="Administrator membership changed",
            confidence=95,
        )

    save(path, current)



def sha256_file(path):
    h = hashlib.sha256()

    with open(path, "rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)

    return h.hexdigest()


def protected_files():
    home = Path.home()

    candidates = [
        Path("/etc/hosts"),
        home / ".zshrc",
        home / ".ssh" / "authorized_keys",
        home / ".ssh" / "config",
        home / "Library" / "LaunchAgents" /
            "io.999intelligence.level6-endpoint.plist",
        Path.home() / "Downloads" / "999_XXX" /
            "endpoint_sensor" / "test" / "integrity_probe.txt",
    ]

    return [path for path in candidates if path.exists() and path.is_file()]


def check_file_integrity():
    state_path = STATE / "file_integrity.json"

    current = {}

    for path in protected_files():
        try:
            current[str(path)] = {
                "sha256": sha256_file(path),
                "size": path.stat().st_size,
            }
        except OSError:
            continue

    previous = load(state_path)

    if previous is None:
        save(state_path, current)
        return

    for path, value in current.items():
        if path not in previous:
            send_event(
                "FILE_INTEGRITY_CHANGE",
                item_path=path,
                current_value=json.dumps(value),
                details="New protected file entered the integrity baseline",
                rule_name="Protected file added",
                confidence=75,
            )
            continue

        if value.get("sha256") != previous[path].get("sha256"):
            send_event(
                "FILE_INTEGRITY_CHANGE",
                item_path=path,
                previous_value=json.dumps(previous[path]),
                current_value=json.dumps(value),
                details="SHA-256 changed for a protected file",
                rule_name="Protected file integrity changed",
                confidence=90,
            )

    for path in previous.keys() - current.keys():
        send_event(
            "FILE_INTEGRITY_CHANGE",
            item_path=path,
            previous_value=json.dumps(previous[path]),
            details="Previously protected file is no longer present",
            rule_name="Protected file removed",
            confidence=90,
        )

    save(state_path, current)


def get_outbound_patterns():
    query = '''
    SELECT
      p.name,
      p.path,
      s.remote_address,
      s.remote_port,
      s.protocol
    FROM process_open_sockets s
    LEFT JOIN processes p
      ON p.pid = s.pid
    WHERE
      s.remote_port > 0
      AND s.remote_address != ''
      AND s.remote_address != '0.0.0.0'
      AND s.remote_address != '::'
      AND s.remote_address != '127.0.0.1'
      AND s.remote_address != '::1';
    '''

    raw = subprocess.check_output(
        ["/usr/local/bin/osqueryi", "--json", query],
        text=True,
    )

    rows = json.loads(raw)
    patterns = {}

    for row in rows:
        name = row.get("name") or ""
        path = row.get("path") or ""
        remote_port = int(row.get("remote_port") or 0)
        protocol = str(row.get("protocol") or "")
        remote_address = row.get("remote_address") or ""

        if remote_port <= 0:
            continue

        # Baseline by process + destination service rather than every IP.
        # This avoids treating normal CDN/IP rotation as an attack.
        key = f"{name}|{path}|{remote_port}|{protocol}"

        patterns[key] = {
            "name": name,
            "path": path,
            "remote_port": remote_port,
            "protocol": protocol,
            "sample_remote_address": remote_address,
        }

    return patterns


def check_outbound_connections():
    state_path = STATE / "outbound_patterns.json"

    current = get_outbound_patterns()
    previous = load(state_path)

    if previous is None:
        save(state_path, current)
        return

    for key, item in current.items():
        if key in previous:
            continue

        send_event(
            "SECURITY_BASELINE_CHANGE",
            process_name=item.get("name"),
            process_path=item.get("path"),
            port=item.get("remote_port"),
            protocol=item.get("protocol"),
            details=(
                "New outbound network pattern observed; "
                "not automatically classified as an attack. "
                f"Sample destination: {item.get('sample_remote_address')}:"
                f"{item.get('remote_port')}"
            ),
            rule_name="New outbound network pattern",
            confidence=65,
        )

    save(state_path, current)



def correlation_state_path():
    return STATE / "recent_signals.json"


def record_signal(signal_type, details=None):
    now = datetime.now(timezone.utc)

    path = correlation_state_path()
    previous = load(path) or []

    cutoff = now.timestamp() - 600

    recent = []

    for item in previous:
        try:
            ts = datetime.fromisoformat(item["timestamp"]).timestamp()
        except Exception:
            continue

        if ts >= cutoff:
            recent.append(item)

    recent.append({
        "timestamp": now.isoformat(),
        "signal_type": signal_type,
        "details": details,
    })

    save(path, recent)

    return recent


def evaluate_correlation(signal_type, details=None):
    recent = record_signal(signal_type, details)

    types = {item.get("signal_type") for item in recent}

    correlated_sets = [
        {
            "NEW_PERSISTENCE_ITEM",
            "SUSPICIOUS_PROCESS",
            "SECURITY_BASELINE_CHANGE",
        },
        {
            "PERSISTENCE_ITEM_CHANGED",
            "SUSPICIOUS_PROCESS",
            "SECURITY_BASELINE_CHANGE",
        },
        {
            "FILE_INTEGRITY_CHANGE",
            "SUSPICIOUS_PROCESS",
            "SECURITY_BASELINE_CHANGE",
        },
        {
            "FAILED_LOGIN_BURST",
            "PRIVILEGE_CHANGE",
        },
        {
            "SIP_DISABLED",
            "SECURITY_TOOL_DISABLED",
        },
    ]

    for required in correlated_sets:
        if not required.issubset(types):
            continue

        marker = STATE / (
            "correlation_" +
            "_".join(sorted(required)) +
            ".marker"
        )

        if marker.exists():
            try:
                age = datetime.now().timestamp() - marker.stat().st_mtime
                if age < 600:
                    return
            except OSError:
                pass

        send_event(
            "SECURITY_BASELINE_CHANGE",
            details=(
                "High-confidence correlation: " +
                ", ".join(sorted(required))
            ),
            rule_name="High confidence correlated endpoint threat",
            confidence=95,
        )

        marker.touch()
        return


def main():
    check_security_controls()
    check_ports()
    check_persistence()
    check_failed_logins()
    check_suspicious_processes()
    check_admin_membership()
    check_file_integrity()
    check_outbound_connections()

    extended_result = run_extended_checks(
        state=STATE,
        load=load,
        save=save,
        send_event=send_event,
    )


    try:
        threat_result = run_threat_intel(send_event)
        print("THREAT_INTEL:", threat_result)
    except Exception as error:
        print("THREAT_INTEL warning:", error)

    try:
        zeek_result = run_zeek_monitor(send_event)
        print("ZEEK:", zeek_result)
    except Exception as error:
        print("ZEEK warning:", error)

    try:
        yara_result = run_yara_monitor(send_event)
        print("YARA:", yara_result)
    except Exception as error:
        print("YARA warning:", error)

    if extended_result.get("errors"):
        print(
            "Extended detection warnings:",
            extended_result["errors"],
        )

    print(
        json.dumps(
            {
                "status": "OK",
                "endpoint": ENDPOINT_ID,
                "checked_at": datetime.now(timezone.utc).isoformat(),
            }
        )
    )

if __name__ == "__main__":
    main()
