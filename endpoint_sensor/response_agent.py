#!/usr/bin/env python3

import hashlib
import json
import os
import shutil
import subprocess
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path


BASE_URL = "https://999-cipher-level6-collector.jontarius.workers.dev"
ENDPOINT_ID = "macbook-primary"

ROOT = Path(__file__).resolve().parent
QUARANTINE = ROOT / "quarantine"
QUARANTINE.mkdir(parents=True, exist_ok=True)

PROTECTED_PREFIXES = (
    "/System",
    "/usr",
    "/bin",
    "/sbin",
    "/Library/Apple",
)

PROTECTED_FILES = {
    Path(__file__).resolve(),
    (ROOT / "level6_mac_sensor.py").resolve(),
}

ALLOWED_COMMANDS = {
    "QUARANTINE_FILE",
}


def keychain_secret():
    result = subprocess.run(
        [
            "/usr/bin/security",
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
        raise RuntimeError("Endpoint sensor credential not found in Keychain")

    return result.stdout.strip()


def api_request(path, method="GET", body=None):
    headers = {
        "Authorization": f"Bearer {keychain_secret()}",
        "Accept": "application/json",
        "User-Agent": "999-Cipher-Level6-Response-Agent/1.0",
    }

    data = None

    if body is not None:
        data = json.dumps(body).encode()
        headers["Content-Type"] = "application/json"

    req = urllib.request.Request(
        f"{BASE_URL}{path}",
        data=data,
        method=method,
        headers=headers,
    )

    with urllib.request.urlopen(req, timeout=15) as response:
        raw = response.read().decode()

    return json.loads(raw)


def sha256_file(path):
    digest = hashlib.sha256()

    with path.open("rb") as handle:
        while True:
            chunk = handle.read(1024 * 1024)

            if not chunk:
                break

            digest.update(chunk)

    return digest.hexdigest()


def reject_reason(path):
    try:
        resolved = path.resolve(strict=True)
    except Exception:
        return "Target path does not exist"

    if not resolved.is_file():
        return "Target is not a regular file"

    if resolved in PROTECTED_FILES:
        return "Level 6 sensor files cannot be quarantined"

    for prefix in PROTECTED_PREFIXES:
        if str(resolved) == prefix or str(resolved).startswith(prefix + "/"):
            return f"Protected system path rejected: {prefix}"

    try:
        quarantine_root = QUARANTINE.resolve()

        if resolved == quarantine_root or quarantine_root in resolved.parents:
            return "File is already inside the quarantine vault"
    except Exception:
        pass

    return None


def report_result(command_id, status, message, evidence=None):
    return api_request(
        f"/endpoint/commands/{urllib.parse.quote(command_id)}/result",
        method="POST",
        body={
            "endpoint_id": ENDPOINT_ID,
            "status": status,
            "message": message,
            "evidence": evidence or {},
        },
    )


def accept_command(command_id):
    return api_request(
        f"/endpoint/commands/{urllib.parse.quote(command_id)}/accept",
        method="POST",
        body={
            "endpoint_id": ENDPOINT_ID,
        },
    )


def quarantine_file(command):
    command_id = command["id"]

    if command.get("endpoint_id") != ENDPOINT_ID:
        return

    if command.get("command_type") not in ALLOWED_COMMANDS:
        return

    target_raw = str(command.get("target_path") or "").strip()

    if not target_raw:
        return

    target = Path(target_raw)

    reason = reject_reason(target)

    if reason:
        print(f"REJECTED {command_id}: {reason}")

        try:
            accept_command(command_id)
            report_result(
                command_id,
                "REJECTED",
                reason,
                {
                    "target_path": target_raw,
                },
            )
        except Exception as error:
            print(f"Result reporting failed: {error}")

        return

    try:
        accepted = accept_command(command_id)

        if not accepted.get("ok"):
            print(f"Command not accepted: {command_id}")
            return
    except Exception as error:
        print(f"Accept failed {command_id}: {error}")
        return

    try:
        resolved = target.resolve(strict=True)

        before_hash = sha256_file(resolved)
        before_size = resolved.stat().st_size

        stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")

        destination = QUARANTINE / (
            f"{command_id}_{stamp}_{resolved.name}"
        )

        if destination.exists():
            raise RuntimeError("Quarantine destination already exists")

        shutil.move(str(resolved), str(destination))

        if resolved.exists():
            raise RuntimeError("Original file still exists after quarantine")

        if not destination.exists():
            raise RuntimeError("Quarantined file was not found after move")

        after_hash = sha256_file(destination)

        if before_hash != after_hash:
            raise RuntimeError("SHA-256 mismatch after quarantine move")

        os.chmod(destination, 0o600)

        evidence = {
            "original_path": str(resolved),
            "quarantine_path": str(destination),
            "sha256": before_hash,
            "size_bytes": before_size,
            "quarantined_at": datetime.now(timezone.utc).isoformat(),
        }

        report_result(
            command_id,
            "SUCCEEDED",
            "File quarantined successfully",
            evidence,
        )

        print(f"QUARANTINED: {resolved}")
        print(f"SHA256: {before_hash}")
        print(f"VAULT: {destination}")

    except Exception as error:
        print(f"FAILED {command_id}: {error}")

        try:
            report_result(
                command_id,
                "FAILED",
                str(error),
                {
                    "target_path": target_raw,
                },
            )
        except Exception as report_error:
            print(f"Failure reporting also failed: {report_error}")


def fetch_commands():
    endpoint = urllib.parse.quote(ENDPOINT_ID)

    result = api_request(
        f"/endpoint/commands?endpoint_id={endpoint}"
    )

    return result.get("commands") or []


def main():
    commands = fetch_commands()

    print(
        json.dumps(
            {
                "endpoint": ENDPOINT_ID,
                "pending_commands": len(commands),
                "checked_at": datetime.now(timezone.utc).isoformat(),
            }
        )
    )

    for command in commands:
        quarantine_file(command)


if __name__ == "__main__":
    main()
