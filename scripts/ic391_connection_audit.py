from pathlib import Path
from datetime import datetime, timezone
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError
import json
import shutil
import socket

ROOT = Path("data/intelligence")
REGISTRY = ROOT / "source_registry.json"
MANIFEST = ROOT / "connection_manifest.json"
REPORT = ROOT / "connection_audit.txt"

print("=== IC391DEA UNIFIED CONNECTION AUDIT ===")

if not REGISTRY.exists():
    raise SystemExit("ERROR: Source registry missing.")

data = json.loads(REGISTRY.read_text(encoding="utf-8"))
sources = data.get("sources", [])

if not isinstance(sources, list):
    raise SystemExit("ERROR: Invalid source registry.")

print("REGISTERED SOURCES:", len(sources))

socket.setdefaulttimeout(8)

results = []

for source in sources:
    sid = source.get("id", "unknown")
    name = source.get("name", sid)
    url = source.get("official_site", "")
    status = source.get("status", "unknown")

    result = {
        "source_id": sid,
        "name": name,
        "registered_status": status,
        "records_loaded": source.get("records_loaded", 0),
        "official_site": url,
        "website_reachable": None,
        "feed_verified": False,
        "connection_enabled": bool(
            source.get("enabled", False)
        ),
        "checked_at": datetime.now(
            timezone.utc
        ).isoformat(),
    }

    print("\nSOURCE:", name)
    print("STATUS:", status)

    if url.startswith("https://"):
        try:
            request = Request(
                url,
                headers={
                    "User-Agent":
                    "IC391DEA-SourceAudit/1.0"
                },
                method="HEAD"
            )

            with urlopen(request, timeout=8) as response:
                code = response.status
                result["website_reachable"] = (
                    200 <= code < 400
                )
                print("HTTP STATUS:", code)

        except HTTPError as e:
            result["website_reachable"] = False
            print("HTTP STATUS:", e.code)

        except (URLError, TimeoutError, OSError) as e:
            result["website_reachable"] = False
            print("WEBSITE CHECK:", type(e).__name__)
    else:
        print("WEBSITE: NOT CONFIGURED")

    if sid == "fbi":
        print("LOCAL FBI SNAPSHOT: REGISTERED")
    else:
        print("DATA FEED: NOT YET VERIFIED")

    results.append(result)

manifest = {
    "schema_version": 1,
    "generated_at": datetime.now(
        timezone.utc
    ).isoformat(),
    "purpose": "Public-source connection verification",
    "external_case_data_transmitted": False,
    "website_checks_are_not_feed_verification": True,
    "sources": results
}

if MANIFEST.exists():
    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup = ROOT / (
        "connection_manifest.backup_" + stamp + ".json"
    )
    shutil.copy2(MANIFEST, backup)

temp = MANIFEST.with_suffix(".json.tmp")
temp.write_text(
    json.dumps(manifest, indent=2),
    encoding="utf-8"
)
temp.replace(MANIFEST)

print("\n=== FINAL CONNECTION SUMMARY ===")
print("SOURCES REGISTERED:", len(results))
print(
    "WEBSITES REACHABLE:",
    sum(r["website_reachable"] is True for r in results)
)
print(
    "VERIFIED LIVE FEEDS:",
    sum(r["feed_verified"] for r in results)
)
print("FBI LOCAL RECORDS:", next(
    (r["records_loaded"] for r in results
     if r["source_id"] == "fbi"), 0
))
print("EXTERNAL CASE DATA TRANSMITTED: NO")
print("EXISTING FBI DATABASE MODIFIED: NO")
print("CONNECTION MANIFEST:", MANIFEST)
print("PHASE 2 AUDIT COMPLETE")
