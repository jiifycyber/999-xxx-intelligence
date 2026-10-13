#!/usr/bin/env python3

import json
import subprocess
from pathlib import Path


BASE = Path.home() / "Downloads/999_XXX"
RULES = BASE / "endpoint_sensor/yara/rules"
STATE = BASE / "endpoint_sensor/state/yara_matches.json"
COMPILED_RULES = BASE / "endpoint_sensor/state/yara_production.yarc"
YARA_BIN = "/opt/homebrew/bin/yara"
YARAC_BIN = "/opt/homebrew/bin/yarac"

SCAN_ROOTS = [
    Path.home() / "Downloads",
    Path("/tmp"),
    Path("/private/tmp"),
]


def load_state():
    try:
        return set(json.loads(STATE.read_text()))
    except Exception:
        return set()


def save_state(items):
    STATE.parent.mkdir(parents=True, exist_ok=True)
    STATE.write_text(json.dumps(sorted(items), indent=2))


def scan():
    rule_files = sorted(RULES.glob("*.yar"))

    if not rule_files:
        return []

    STATE.parent.mkdir(parents=True, exist_ok=True)

    newest_rule = max(rule.stat().st_mtime for rule in rule_files)

    needs_compile = (
        not COMPILED_RULES.exists()
        or COMPILED_RULES.stat().st_mtime < newest_rule
    )

    if needs_compile:
        import re

        print(f"YARA: compiling {len(rule_files)} production rules...")

        externals = {
            "filename": "",
            "filepath": "",
            "extension": "",
            "filetype": "",
        }

        while True:
            external_args = []

            for name, value in sorted(externals.items()):
                external_args.extend(["-d", f"{name}={value}"])

            result = subprocess.run(
                [
                    YARAC_BIN,
                    *external_args,
                    *[str(rule) for rule in rule_files],
                    str(COMPILED_RULES),
                ],
                text=True,
                capture_output=True,
            )

            if result.returncode == 0:
                break

            error_text = (result.stderr or "") + "\n" + (result.stdout or "")

            missing = set(
                re.findall(
                    r'undefined identifier "([^"]+)"',
                    error_text,
                )
            )

            new_missing = missing - set(externals)

            if not new_missing:
                raise RuntimeError(
                    "YARA rule compilation failed:\n" + error_text
                )

            for identifier in sorted(new_missing):
                externals[identifier] = ""
                print(
                    f"YARA: discovered external variable: {identifier}"
                )

        print(
            "YARA: production rules compiled "
            f"with {len(externals)} external variables."
        )

    matches = []
    seen_roots = set()

    yara_data_root = (BASE / "endpoint_sensor/yara").resolve()
    sensor_state_root = (BASE / "endpoint_sensor/state").resolve()
    quarantine_root = (BASE / "endpoint_sensor/quarantine").resolve()

    for root in SCAN_ROOTS:
        if not root.exists():
            continue

        resolved_root = root.resolve()

        if str(resolved_root) in seen_roots:
            continue

        seen_roots.add(str(resolved_root))

        result = subprocess.run(
            [
                YARA_BIN,
                "-C",
                "-r",
                str(COMPILED_RULES),
                str(root),
            ],
            text=True,
            capture_output=True,
        )

        if result.returncode not in (0, 1):
            raise RuntimeError(
                f"YARA scan failed for {root}:\n"
                + (result.stderr or result.stdout)
            )

        for line in result.stdout.splitlines():
            line = line.strip()

            if not line:
                continue

            parts = line.split(maxsplit=1)

            if len(parts) != 2:
                continue

            rule, path = parts

            try:
                matched_path = Path(path).resolve()

                if (
                    matched_path == yara_data_root
                    or yara_data_root in matched_path.parents
                    or matched_path == sensor_state_root
                    or sensor_state_root in matched_path.parents
                    or matched_path == quarantine_root
                    or quarantine_root in matched_path.parents
                ):
                    continue
            except Exception:
                pass

            matches.append(
                {
                    "rule": rule,
                    "path": path,
                }
            )

    unique = {}

    for item in matches:
        fingerprint = f'{item["rule"]}|{item["path"]}'
        unique[fingerprint] = item

    return list(unique.values())

def run(send_event):
    old = load_state()
    current = scan()

    fingerprints = set()

    for item in current:
        fingerprint = f'{item["rule"]}|{item["path"]}'
        fingerprints.add(fingerprint)

        if fingerprint in old:
            continue

        is_test = item["rule"] in {
            "LEVEL6_CONTROLLED_TEST",
            "CIPHER_SAFE_TEST_DETECTION",
        }

        send_event(
            "SECURITY_BASELINE_CHANGE",
            details=(
                f'YARA rule {item["rule"]} matched '
                f'{item["path"]}'
            ),
            rule_name=(
                "TEST - YARA detection pipeline"
                if is_test
                else f'YARA signature match - {item["rule"]}'
            ),
            confidence=(
                60 if is_test else 95
            ),
            item_path=item["path"],
        )

    save_state(fingerprints)

    return {
        "matches": len(current),
        "new_matches": len(
            fingerprints - old
        ),
    }
