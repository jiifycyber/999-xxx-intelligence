#!/usr/bin/env python3

import json
from pathlib import Path


BASE = Path.home() / "Downloads/999_XXX"
LIVE = BASE / "endpoint_sensor/zeek/live"
STATE = BASE / "endpoint_sensor/state/zeek_monitor.json"


def load_state():
    try:
        value = json.loads(STATE.read_text())
        return value if isinstance(value, dict) else {}
    except Exception:
        return {}


def save_state(value):
    STATE.parent.mkdir(parents=True, exist_ok=True)
    STATE.write_text(
        json.dumps(value, indent=2, sort_keys=True)
    )


def read_zeek_tsv(path):
    if not path.exists():
        return []

    fields = None
    rows = []

    try:
        lines = path.read_text(
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


def notice_fingerprint(row):
    return "|".join(
        [
            row.get("ts", ""),
            row.get("note", ""),
            row.get("msg", ""),
            row.get("src", ""),
            row.get("dst", ""),
        ]
    )


def run(send_event):
    state = load_state()

    previous_notices = set(
        state.get("notice_fingerprints", [])
    )

    notices = read_zeek_tsv(
        LIVE / "notice.log"
    )

    current_notices = {
        notice_fingerprint(row)
        for row in notices
    }

    new_notices = (
        current_notices - previous_notices
    )

    # First run establishes the Zeek baseline.
    first_run = "initialized" not in state

    sent = 0

    if not first_run:
        for row in notices:
            fp = notice_fingerprint(row)

            if fp not in new_notices:
                continue

            note = row.get("note", "Zeek notice")
            msg = row.get("msg", "")
            src = row.get("src", "-")
            dst = row.get("dst", "-")

            send_event(
                "SECURITY_BASELINE_CHANGE",
                details=(
                    f"Zeek notice={note}; "
                    f"source={src}; destination={dst}; "
                    f"message={msg}"
                ),
                rule_name=f"Zeek network notice - {note}",
                confidence=80,
            )

            sent += 1

    dns_rows = read_zeek_tsv(
        LIVE / "dns.log"
    )

    nxdomain_count = sum(
        1
        for row in dns_rows
        if row.get("rcode_name", "").upper()
        == "NXDOMAIN"
    )

    previous_nxdomain_alert = bool(
        state.get("nxdomain_burst_active")
    )

    nxdomain_burst = nxdomain_count >= 25

    if (
        not first_run
        and nxdomain_burst
        and not previous_nxdomain_alert
    ):
        send_event(
            "SECURITY_BASELINE_CHANGE",
            details=(
                "Zeek observed at least 25 NXDOMAIN "
                "DNS responses in the current log window"
            ),
            rule_name="Zeek DNS failure burst",
            confidence=70,
        )
        sent += 1

    conn_rows = read_zeek_tsv(
        LIVE / "conn.log"
    )

    rejected = sum(
        1
        for row in conn_rows
        if row.get("conn_state") == "REJ"
    )

    previous_reject_alert = bool(
        state.get("reject_burst_active")
    )

    reject_burst = rejected >= 30

    if (
        not first_run
        and reject_burst
        and not previous_reject_alert
    ):
        send_event(
            "SECURITY_BASELINE_CHANGE",
            details=(
                "Zeek observed at least 30 rejected "
                "connections in the current log window"
            ),
            rule_name="Zeek rejected connection burst",
            confidence=70,
        )
        sent += 1

    state = {
        "initialized": True,
        "notice_fingerprints": sorted(
            current_notices
        )[-500:],
        "nxdomain_burst_active": nxdomain_burst,
        "reject_burst_active": reject_burst,
        "dns_rows": len(dns_rows),
        "conn_rows": len(conn_rows),
        "notice_rows": len(notices),
    }

    save_state(state)

    return {
        "connections": len(conn_rows),
        "dns": len(dns_rows),
        "notices": len(notices),
        "events_sent": sent,
    }
