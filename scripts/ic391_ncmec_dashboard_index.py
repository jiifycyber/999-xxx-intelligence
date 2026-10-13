import json
from pathlib import Path
from datetime import datetime, timezone
from urllib.parse import urlparse, parse_qs
from collections import Counter

ROOT = Path("data/intelligence")
SOURCE = ROOT / "staging/ncmec_records.json"
OUTPUT = ROOT / "dashboard/ncmec_index.json"
SUMMARY = ROOT / "dashboard/ncmec_summary.json"

print("=== IC391DEA NCMEC DASHBOARD INDEX ===")

if not SOURCE.exists():
    raise SystemExit("ERROR: NCMEC staging file missing")

payload = json.loads(SOURCE.read_text(encoding="utf-8"))
records = payload.get("records", [])

if not isinstance(records, list):
    raise SystemExit("ERROR: Invalid records array")

indexed = []
states = Counter()
seen = set()
skipped = 0

for record in records:
    if not isinstance(record, dict):
        skipped += 1
        continue

    uid = str(record.get("global_id") or "").strip()
    details = record.get("details") or {}

    if not isinstance(details, dict):
        details = {}

    feed = str(details.get("feed_url") or "")
    link = str(record.get("source_url") or "")

    if not uid or uid in seen:
        skipped += 1
        continue

    if urlparse(link).hostname not in (
        "missingkids.org",
        "www.missingkids.org"
    ):
        skipped += 1
        continue

    seen.add(uid)

    query = parse_qs(urlparse(feed).query)
    state = query.get("state", ["UNKNOWN"])[0].upper()

    if len(state) != 2 or not state.isalpha():
        state = "UNKNOWN"

    states[state] += 1

    indexed.append({
        "global_id": uid,
        "source_id": "ncmec",
        "title": record.get("title"),
        "state": state,
        "source_url": link,
        "published": details.get("published"),
        "description": details.get("description"),
        "feed_url": feed,
        "source_verified": True,
        "case_status_verified": False,
        "missing_child_classification": "pending_review",
        "cross_source_match": "not_evaluated",
        "review_required": True
    })

generated = datetime.now(timezone.utc).isoformat()

dashboard = {
    "schema_version": 1,
    "generated_at": generated,
    "source": "NCMEC public RSS",
    "records": indexed,
    "public_release_approved": False
}

summary = {
    "generated_at": generated,
    "total_indexed": len(indexed),
    "skipped": skipped,
    "state_counts": dict(sorted(states.items())),
    "verified_active_cases": None,
    "fbi_database_modified": False,
    "automatic_case_sharing": False
}

for path, content in [
    (OUTPUT, dashboard),
    (SUMMARY, summary)
]:
    temp = path.with_suffix(".json.tmp")
    temp.write_text(
        json.dumps(content, indent=2, ensure_ascii=False),
        encoding="utf-8"
    )
    temp.replace(path)

print("INDEXED RECORDS:", len(indexed))
print("SKIPPED RECORDS:", skipped)
print("JURISDICTIONS:", len(states))
print("ACTIVE CASE STATUS: PENDING REVIEW")
print("FBI DATABASE: UNCHANGED")
print("PUBLIC RELEASE: DISABLED")
print("DASHBOARD INDEX:", OUTPUT)
print("SUMMARY:", SUMMARY)
print("PHASE 9 COMPLETE")
