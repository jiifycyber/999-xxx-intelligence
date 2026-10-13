#!/usr/bin/env python3

import hashlib
import json
import os
import plistlib
import subprocess
from pathlib import Path


def _cmd(command):
    result = subprocess.run(
        command,
        shell=True,
        text=True,
        capture_output=True,
    )
    return result.stdout.strip()


def _hash_text(value):
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def _hash_file(path):
    h = hashlib.sha256()

    with open(path, "rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)

    return h.hexdigest()


def _snapshot(
    *,
    state,
    load,
    save,
    send_event,
    filename,
    current,
    rule_name,
    confidence=75,
    event_type="SECURITY_BASELINE_CHANGE",
):
    path = state / filename
    previous = load(path)

    if previous is None:
        save(path, current)
        return

    if previous != current:
        send_event(
            event_type,
            previous_value=json.dumps(previous, sort_keys=True),
            current_value=json.dumps(current, sort_keys=True),
            details=f"{rule_name} changed from established endpoint baseline",
            rule_name=rule_name,
            confidence=confidence,
        )

    save(path, current)


def check_dns(state, load, save, send_event):
    output = _cmd("/usr/sbin/scutil --dns 2>/dev/null")

    current = {
        "sha256": _hash_text(output),
        "summary": [
            line.strip()
            for line in output.splitlines()
            if "nameserver[" in line
            or "search domain" in line.lower()
            or "domain :" in line.lower()
        ][:30],
    }

    _snapshot(
        state=state,
        load=load,
        save=save,
        send_event=send_event,
        filename="dns_config.json",
        current=current,
        rule_name="DNS configuration changed",
        confidence=85,
    )


def check_proxy(state, load, save, send_event):
    output = _cmd("/usr/sbin/scutil --proxy 2>/dev/null")

    current = {
        "sha256": _hash_text(output),
        "configuration": output.splitlines()[:80],
    }

    _snapshot(
        state=state,
        load=load,
        save=save,
        send_event=send_event,
        filename="proxy_config.json",
        current=current,
        rule_name="Proxy or network routing configuration changed",
        confidence=85,
    )


def check_firewall(state, load, save, send_event):
    tool = (
        "/usr/libexec/ApplicationFirewall/socketfilterfw"
    )

    if not Path(tool).exists():
        return

    output = _cmd(f'"{tool}" --getglobalstate 2>/dev/null')

    current = {
        "global_state": output,
    }

    _snapshot(
        state=state,
        load=load,
        save=save,
        send_event=send_event,
        filename="firewall_state.json",
        current=current,
        rule_name="macOS firewall state changed",
        confidence=90,
    )


def check_local_users(state, load, save, send_event):
    output = _cmd(
        "dscl . -list /Users UniqueID 2>/dev/null"
    )

    users = []

    for line in output.splitlines():
        parts = line.split()

        if len(parts) < 2:
            continue

        try:
            uid = int(parts[-1])
        except ValueError:
            continue

        if uid >= 500:
            users.append(
                {
                    "username": " ".join(parts[:-1]),
                    "uid": uid,
                }
            )

    users.sort(key=lambda item: (item["uid"], item["username"]))

    _snapshot(
        state=state,
        load=load,
        save=save,
        send_event=send_event,
        filename="local_users.json",
        current=users,
        rule_name="Local user account inventory changed",
        confidence=90,
        event_type="PRIVILEGE_CHANGE",
    )


def check_ssh(state, load, save, send_event):
    home = Path.home()

    paths = [
        home / ".ssh" / "authorized_keys",
        home / ".ssh" / "config",
        Path("/etc/ssh/sshd_config"),
    ]

    current = {}

    for path in paths:
        if not path.exists() or not path.is_file():
            continue

        try:
            current[str(path)] = {
                "sha256": _hash_file(path),
                "size": path.stat().st_size,
            }
        except OSError:
            pass

    _snapshot(
        state=state,
        load=load,
        save=save,
        send_event=send_event,
        filename="ssh_integrity.json",
        current=current,
        rule_name="SSH configuration or authorized keys changed",
        confidence=95,
        event_type="FILE_INTEGRITY_CHANGE",
    )


def check_usb(state, load, save, send_event):
    output = _cmd(
        "/usr/sbin/system_profiler SPUSBDataType -json 2>/dev/null"
    )

    try:
        parsed = json.loads(output) if output else {}
    except Exception:
        parsed = {"raw_sha256": _hash_text(output)}

    current = {
        "sha256": _hash_text(
            json.dumps(parsed, sort_keys=True)
        )
    }

    _snapshot(
        state=state,
        load=load,
        save=save,
        send_event=send_event,
        filename="usb_devices.json",
        current=current,
        rule_name="USB device inventory changed",
        confidence=70,
    )


def check_system_extensions(state, load, save, send_event):
    tool = "/usr/bin/systemextensionsctl"

    if not Path(tool).exists():
        return

    output = _cmd(
        f"{tool} list 2>/dev/null"
    )

    current = {
        "sha256": _hash_text(output),
        "extensions": [
            line.strip()
            for line in output.splitlines()
            if line.strip()
        ][:100],
    }

    _snapshot(
        state=state,
        load=load,
        save=save,
        send_event=send_event,
        filename="system_extensions.json",
        current=current,
        rule_name="System or network extension inventory changed",
        confidence=85,
    )


def check_browser_extensions(state, load, save, send_event):
    home = Path.home()

    roots = [
        home
        / "Library/Application Support/Google/Chrome/Default/Extensions",
        home
        / "Library/Application Support/Google/Chrome/Profile 1/Extensions",
        home
        / "Library/Application Support/Microsoft Edge/Default/Extensions",
    ]

    current = []

    for root in roots:
        if not root.exists():
            continue

        try:
            items = list(root.iterdir())
        except PermissionError:
            continue
        except OSError:
            continue

        for item in items:
            try:
                if item.is_dir():
                    current.append(
                        {
                            "browser_root": str(root),
                            "extension_id": item.name,
                        }
                    )
            except OSError:
                continue

    current.sort(
        key=lambda item: (
            item["browser_root"],
            item["extension_id"],
        )
    )

    _snapshot(
        state=state,
        load=load,
        save=save,
        send_event=send_event,
        filename="browser_extensions.json",
        current=current,
        rule_name="Browser extension inventory changed",
        confidence=75,
    )


def check_additional_persistence(state, load, save, send_event):
    home = Path.home()

    files = [
        home / ".zshrc",
        home / ".zprofile",
        home / ".bash_profile",
        home / ".bashrc",
        Path("/etc/crontab"),
    ]

    current = {}

    for path in files:
        if not path.exists() or not path.is_file():
            continue

        try:
            current[str(path)] = {
                "sha256": _hash_file(path),
                "size": path.stat().st_size,
            }
        except OSError:
            pass

    current["user_crontab"] = _cmd(
        "crontab -l 2>/dev/null"
    )

    _snapshot(
        state=state,
        load=load,
        save=save,
        send_event=send_event,
        filename="extended_persistence.json",
        current=current,
        rule_name="Shell or scheduled persistence configuration changed",
        confidence=85,
        event_type="FILE_INTEGRITY_CHANGE",
    )


def check_remote_access(state, load, save, send_event):
    indicators = {
        "ssh_listener": bool(
            _cmd(
                "lsof -nP -iTCP:22 -sTCP:LISTEN 2>/dev/null"
            )
        ),
        "vnc_listener": bool(
            _cmd(
                "lsof -nP -iTCP:5900 -sTCP:LISTEN 2>/dev/null"
            )
        ),
        "ard_process": bool(
            _cmd(
                "pgrep -f 'ARDAgent|screensharingd' 2>/dev/null"
            )
        ),
    }

    _snapshot(
        state=state,
        load=load,
        save=save,
        send_event=send_event,
        filename="remote_access.json",
        current=indicators,
        rule_name="Remote access capability changed",
        confidence=90,
    )


def check_vm_container_activity(state, load, save, send_event):
    names = [
        "docker",
        "Docker",
        "qemu",
        "VirtualBox",
        "VBox",
        "vmware",
        "podman",
        "colima",
        "multipass",
    ]

    output = _cmd(
        "ps -axo pid=,comm=,args= 2>/dev/null"
    )

    matches = []

    for line in output.splitlines():
        lower = line.lower()

        if any(name.lower() in lower for name in names):
            matches.append(line.strip()[:500])

    current = sorted(set(matches))

    _snapshot(
        state=state,
        load=load,
        save=save,
        send_event=send_event,
        filename="vm_container_activity.json",
        current=current,
        rule_name="Virtual machine or container activity changed",
        confidence=70,
    )


def check_download_process_signatures(send_event):
    query = """
    SELECT DISTINCT
      pid,
      name,
      path
    FROM processes
    WHERE
      path LIKE '%/Downloads/%'
      OR path LIKE '/tmp/%'
      OR path LIKE '/private/tmp/%'
      OR path LIKE '/var/tmp/%';
    """

    try:
        raw = subprocess.check_output(
            ["/usr/local/bin/osqueryi", "--json", query],
            text=True,
        )

        rows = json.loads(raw)
    except Exception:
        return

    for row in rows:
        path = row.get("path") or ""
        name = row.get("name") or ""

        if not path or not Path(path).exists():
            continue

        result = subprocess.run(
            [
                "/usr/bin/codesign",
                "--verify",
                "--deep",
                "--strict",
                path,
            ],
            text=True,
            capture_output=True,
        )

        if result.returncode != 0:
            send_event(
                "SUSPICIOUS_PROCESS",
                process_name=name,
                process_path=path,
                details=(
                    "Running executable from a user/temp location "
                    "did not pass strict code-signature verification"
                ),
                rule_name="Unsigned or invalidly signed running executable",
                confidence=85,
            )


def check_sensor_self_protection(
    *,
    state,
    load,
    save,
    send_event,
):
    home = Path.home()

    targets = [
        home
        / "Downloads/999_XXX/endpoint_sensor/level6_mac_sensor.py",
        home
        / "Downloads/999_XXX/endpoint_sensor/extended_detection_pack.py",
        home
        / "Library/LaunchAgents/io.999intelligence.level6-endpoint.plist",
    ]

    current = {}

    for path in targets:
        if not path.exists():
            current[str(path)] = {
                "exists": False,
            }
            continue

        try:
            current[str(path)] = {
                "exists": True,
                "sha256": _hash_file(path),
                "size": path.stat().st_size,
            }
        except OSError:
            pass

    path = state / "sensor_self_protection.json"
    previous = load(path)

    if previous is None:
        save(path, current)
        return

    if previous != current:
        send_event(
            "SECURITY_TOOL_DISABLED",
            previous_value=json.dumps(previous, sort_keys=True),
            current_value=json.dumps(current, sort_keys=True),
            details=(
                "Level 6 endpoint sensor or its LaunchAgent changed"
            ),
            rule_name="Level 6 sensor integrity changed",
            confidence=95,
        )

    save(path, current)


def run_extended_checks(
    *,
    state,
    load,
    save,
    send_event,
):
    checks = [
        lambda: check_dns(
            state, load, save, send_event
        ),
        lambda: check_proxy(
            state, load, save, send_event
        ),
        lambda: check_firewall(
            state, load, save, send_event
        ),
        lambda: check_local_users(
            state, load, save, send_event
        ),
        lambda: check_ssh(
            state, load, save, send_event
        ),
        lambda: check_usb(
            state, load, save, send_event
        ),
        lambda: check_system_extensions(
            state, load, save, send_event
        ),
        lambda: check_browser_extensions(
            state, load, save, send_event
        ),
        lambda: check_additional_persistence(
            state, load, save, send_event
        ),
        lambda: check_remote_access(
            state, load, save, send_event
        ),
        lambda: check_vm_container_activity(
            state, load, save, send_event
        ),
        lambda: check_download_process_signatures(
            send_event
        ),
        lambda: check_sensor_self_protection(
            state=state,
            load=load,
            save=save,
            send_event=send_event,
        ),
    ]

    errors = []

    for check in checks:
        try:
            check()
        except Exception as error:
            errors.append(str(error))

    return {
        "extended_checks": len(checks),
        "errors": errors,
    }
