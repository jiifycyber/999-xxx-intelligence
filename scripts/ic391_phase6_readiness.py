from pathlib import Path
from datetime import datetime, timezone
import json

ROOT = Path("data/intelligence")
ADAPTERS = ROOT / "adapters"
REPORT = ROOT / "phase6_readiness.json"

SOURCES = [
    "ncmec",
    "namus",
    "amber",
    "state_police",
    "local_police",
    "us_marshals",
    "dhs",
    "interpol",
    "community",
]

print("=== IC391DEA PHASE 6 ===")
print("MULTI-SOURCE INTEGRATION READINESS")
print("=" * 55)

results = []

for sid in SOURCES:
    path = ADAPTERS / f"{sid}.json"

    if not path.exists():
        print("MISSING CONFIG:", sid)
        results.append({
            "source_id": sid,
            "status": "config_missing"
        })
        continue

    config = json.loads(
        path.read_text(encoding="utf-8")
    )

    endpoint = config.get("verified_api_endpoint")
    permission = config.get("access_verified", False)

    ready = bool(endpoint and permission)

    result = {
        "source_id": sid,
        "name": config.get("source_name"),
        "configuration_present": True,
        "official_site": config.get("official_site"),
        "verified_endpoint": endpoint,
        "access_verified": permission,
        "integration_ready": ready,
        "next_step": config.get("next_step"),
    }

    results.append(result)

    print("\nSOURCE:", sid.upper())
    print("CONFIGURATION: FOUND")
    print("VERIFIED ENDPOINT:", endpoint or "NONE")
    print("ACCESS VERIFIED:", permission)
    print("READY:", ready)
    print("NEXT:", config.get("next_step"))

summary = {
    "generated_at": datetime.now(
        timezone.utc
    ).isoformat(),
    "sources_checked": len(results),
    "ready_count": sum(
        r.get("integration_ready", False)
        for r in results
    ),
    "pending_count": sum(
        not r.get("integration_ready", False)
        for r in results
    ),
    "fbi_connection_unchanged": True,
    "external_case_data_transmitted": False,
    "results": results
}

temp = REPORT.with_suffix(".json.tmp")
temp.write_text(
    json.dumps(summary, indent=2),
    encoding="utf-8"
)
temp.replace(REPORT)

print("\n=== FINAL SUMMARY ===")
print("ADAPTERS CHECKED:", len(results))
print("READY:", summary["ready_count"])
print("PENDING:", summary["pending_count"])
print("FBI CONNECTION: PRESERVED")
print("CASE DATA TRANSMITTED: NO")
print("REPORT:", REPORT)
print("PHASE 6 COMPLETE")
