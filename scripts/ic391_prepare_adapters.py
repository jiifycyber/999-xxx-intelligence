from pathlib import Path
from datetime import datetime, timezone
import json
import shutil

ROOT = Path("data/intelligence")
ADAPTERS = ROOT / "adapters"
REGISTRY = ROOT / "source_registry.json"
MANIFEST = ROOT / "adapter_manifest.json"

ADAPTERS.mkdir(parents=True, exist_ok=True)

if not REGISTRY.exists():
    raise SystemExit("ERROR: Source registry missing.")

registry = json.loads(
    REGISTRY.read_text(encoding="utf-8")
)

sources = registry.get("sources", [])

if not isinstance(sources, list):
    raise SystemExit("ERROR: Invalid registry format.")

requirements = {
    "ncmec": {
        "method": "authorized_feed",
        "next_step": "Verify NCMEC data-sharing access"
    },
    "namus": {
        "method": "verified_public_data",
        "next_step": "Identify permitted public export or API"
    },
    "amber": {
        "method": "verified_alert_feed",
        "next_step": "Identify official alert distribution feed"
    },
    "state_police": {
        "method": "public_bulletin_sources",
        "next_step": "Configure individual state agencies"
    },
    "local_police": {
        "method": "public_bulletin_sources",
        "next_step": "Configure individual local agencies"
    },
    "us_marshals": {
        "method": "verified_public_data",
        "next_step": "Verify official public data access"
    },
    "dhs": {
        "method": "verified_public_data",
        "next_step": "Identify relevant public datasets"
    },
    "interpol": {
        "method": "verified_public_notices",
        "next_step": "Verify permitted notices access"
    },
    "community": {
        "method": "private_secure_backend",
        "next_step": "Build protected tip intake and review"
    }
}

prepared = []

print("=== IC391DEA MULTI-SOURCE ADAPTER BUILD ===")

for source in sources:
    sid = source.get("id")

    if sid == "fbi":
        print("FBI: EXISTING CONNECTION PRESERVED")
        continue

    if sid not in requirements:
        print("UNKNOWN SOURCE SKIPPED:", sid)
        continue

    details = requirements[sid]

    config = {
        "schema_version": 1,
        "source_id": sid,
        "source_name": source.get("name"),
        "official_site": source.get("official_site"),
        "connection_method": details["method"],
        "next_step": details["next_step"],
        "status": "pending_verification",
        "enabled": False,
        "records_loaded": 0,
        "last_sync": None,
        "external_transmission_enabled": False,
        "case_sharing_enabled": False,
        "created_at": datetime.now(
            timezone.utc
        ).isoformat()
    }

    target = ADAPTERS / f"{sid}.json"

    if target.exists():
        existing = json.loads(
            target.read_text(encoding="utf-8")
        )
        print("EXISTING CONFIG PRESERVED:", sid)
        prepared.append(existing)
        continue

    temp = target.with_suffix(".json.tmp")
    temp.write_text(
        json.dumps(config, indent=2),
        encoding="utf-8"
    )
    temp.replace(target)

    prepared.append(config)

    print("ADAPTER PREPARED:", sid)

manifest = {
    "schema_version": 1,
    "generated_at": datetime.now(
        timezone.utc
    ).isoformat(),
    "fbi_connection_preserved": True,
    "additional_adapters": prepared,
    "automatic_case_sharing": False,
    "verified_live_feeds_added": 0
}

if MANIFEST.exists():
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    shutil.copy2(
        MANIFEST,
        ROOT / f"adapter_manifest.backup_{stamp}.json"
    )

temp = MANIFEST.with_suffix(".json.tmp")
temp.write_text(
    json.dumps(manifest, indent=2),
    encoding="utf-8"
)
temp.replace(MANIFEST)

print("\n=== BUILD SUMMARY ===")
print("REGISTERED SOURCES:", len(sources))
print("ADAPTER CONFIGURATIONS:", len(prepared))
print("FBI DATABASE: UNCHANGED")
print("NEW LIVE FEEDS: 0")
print("AUTOMATIC CASE SHARING: DISABLED")
print("MANIFEST:", MANIFEST)
print("PHASE 5 PREPARATION COMPLETE")
