#!/usr/bin/env python3

import json
import os
import socket
import subprocess
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent
STATE_DIR = ROOT / "state"
LOG_DIR = ROOT / "logs"

HEALTH_FILE = STATE_DIR / "health_status.json"
WATCHDOG_LOG = LOG_DIR / "health_watchdog.log"

WORKER_URL = (
    "https://999-cipher-level6-collector.jontarius.workers.dev/endpoint/event"
)

ENDPOINT_ID = "macbook-primary"

STALE_SECONDS = 300
RESTART_COOLDOWN_SECONDS = 120

LABEL = "com.999cipher.level6sensor"


def now():
    return datetime.now(timezone.utc)


def iso(dt=None):
    return (dt or now()).isoformat()


def log(message):
    LOG_DIR.mkdir(parents=True, exist_ok=True)

    with WATCHDOG_LOG.open("a") as f:
        f.write(f"{iso()}  {message}\n")


def load_state():
    try:
        if HEALTH_FILE.exists():
            return json.loads(HEALTH_FILE.read_text())
    except Exception as error:
        log(f"STATE READ ERROR: {error}")

    return {}


def save_state(state):
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    HEALTH_FILE.write_text(json.dumps(state, indent=2))


def parse_time(value):
    if not value:
        return None

    try:
        return datetime.fromisoformat(
            str(value).replace("Z", "+00:00")
        )
    except Exception:
        return None


def keychain_secret():
    result = subprocess.run(
        [
            "security",
            "find-generic-password",
            "-a",
            os.environ.get("USER", ""),
            "-s",
            "999-cipher-endpoint-sensor",
            "-w",
        ],
        text=True,
        capture_output=True,
    )

    if result.returncode != 0:
        raise RuntimeError("watchdog credential unavailable")

    return result.stdout.strip()


def report(event_type, details):
    payload = {
        "event_type": event_type,
        "occurred_at": iso(),
        "hostname": socket.gethostname(),
        "endpoint_id": ENDPOINT_ID,
        "confidence": 100,
        "action": "OBSERVED",
        "details": details,
        "rule_name": "999 Cipher Health Watchdog",
    }

    request = urllib.request.Request(
        WORKER_URL,
        data=json.dumps(payload).encode(),
        method="POST",
        headers={
            "Authorization": f"Bearer {keychain_secret()}",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "999-Cipher-Health-Watchdog/1.0",
        },
    )

    with urllib.request.urlopen(request, timeout=15) as response:
        response.read()


def restart_sensor():
    uid = os.getuid()

    result = subprocess.run(
        [
            "launchctl",
            "kickstart",
            "-k",
            f"gui/{uid}/{LABEL}",
        ],
        text=True,
        capture_output=True,
    )

    if result.returncode != 0:
        raise RuntimeError(
            result.stderr.strip()
            or result.stdout.strip()
            or "launchctl restart failed"
        )


def main():
    state = load_state()

    current = now()
    last_success = parse_time(state.get("last_success_at"))
    last_exit = state.get("last_exit_code")

    if last_success is None:
        age = None
    else:
        age = (current - last_success).total_seconds()

    failed_run = (
        last_exit is not None
        and int(last_exit) != 0
    )

    stale = (
        last_success is None
        or age is None
        or age > STALE_SECONDS
    )

    unhealthy = failed_run or stale

    previous = state.get("watchdog_state", "UNKNOWN")

    if not unhealthy:
        state["watchdog_state"] = "HEALTHY"
        state["watchdog_checked_at"] = iso(current)

        if previous in {
            "OFFLINE",
            "DEGRADED",
            "RECOVERING",
        }:
            log("RECOVERY CONFIRMED: Level 6 sensor healthy.")

            try:
                report(
                    "WATCHDOG_RECOVERY",
                    "Level 6 endpoint sensor recovered and heartbeat is healthy.",
                )
            except Exception as error:
                log(f"RECOVERY REPORT WARNING: {error}")

        save_state(state)
        return

    state["watchdog_state"] = "OFFLINE" if stale else "DEGRADED"
    state["watchdog_checked_at"] = iso(current)

    if age is not None:
        state["heartbeat_age_seconds"] = int(age)

    if previous not in {"OFFLINE", "DEGRADED", "RECOVERING"}:
        try:
            report(
                "ENDPOINT_OFFLINE",
                (
                    "999 Cipher Health Watchdog detected unhealthy "
                    f"Level 6 sensor. stale={stale}, "
                    f"last_exit={last_exit}, "
                    f"heartbeat_age={age}"
                ),
            )
        except Exception as error:
            log(f"OFFLINE REPORT WARNING: {error}")

    last_restart = parse_time(state.get("last_restart_attempt_at"))

    cooldown_ok = (
        last_restart is None
        or (current - last_restart).total_seconds()
        >= RESTART_COOLDOWN_SECONDS
    )

    if cooldown_ok:
        state["watchdog_state"] = "RECOVERING"
        state["last_restart_attempt_at"] = iso(current)

        try:
            restart_sensor()
            log("RECOVERY ACTION: Level 6 sensor restart requested.")
        except Exception as error:
            state["watchdog_state"] = "OFFLINE"
            state["last_restart_error"] = str(error)
            log(f"RESTART FAILED: {error}")

    save_state(state)


if __name__ == "__main__":
    main()
