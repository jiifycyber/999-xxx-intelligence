import json
from pathlib import Path
from collections import Counter
from datetime import datetime, timezone
from urllib.parse import urlparse

base = Path("data/intelligence")
fbi_path = base / "unified_records.json"
ncmec_path = base / "dashboard/ncmec_index.json"
output_path = base / "dashboard/unified_missing_children.json"
report_path = base / "dashboard/unified_build_report.json"

def load_records(path):
    if not path.exists():
        raise SystemExit("ERROR: Missing file: " + str(path))
    data = json.loads(path.read_text(encoding="utf-8"))
    records = data.get("records", [])
    if not isinstance(records, list):
        raise SystemExit("ERROR: Invalid records in " + str(path))
    return records

fbi = load_records(fbi_path)
ncmec = load_records(ncmec_path)

unified = []
seen = set()
counts = Counter()
skipped = 0

for source, records in [("fbi", fbi), ("ncmec", ncmec)]:
    for record in records:
        if not isinstance(record, dict):
            skipped += 1
            continue

        uid = str(record.get("global_id") or "").strip()
        if not uid or uid in seen:
            skipped += 1
            continue

        if record.get("source_id") != source:
            skipped += 1
            continue

        seen.add(uid)

        raw = record.get("raw_record") or {}
        if not isinstance(raw, dict):
            raw = {}

        url = str(record.get("source_url") or "")
        host = (urlparse(url).hostname or "").lower()

        if source == "fbi":
            if host != "fbi.gov" and not host.endswith(".fbi.gov"):
                skipped += 1
                continue
        else:
            if host != "missingkids.org" and not host.endswith(".missingkids.org"):
                skipped += 1
                continue

        subjects = record.get("subjects") or []
        if not isinstance(subjects, list):
            subjects = [str(subjects)]

        description = (
            record.get("description")
            or raw.get("description")
            or ""
        )

        unified.append({
            "global_id": uid,
            "source_id": source,
            "source_record_id": str(
                record.get("source_record_id")
                or uid.split(":", 1)[-1]
            ),
            "title": str(record.get("title") or "Untitled"),
            "description": str(description),
            "state": str(record.get("state") or ""),
            "subjects": [str(x) for x in subjects],
            "source_url": url,
            "published": str(
                record.get("published")
                or record.get("publication")
                or ""
            ),
            "review_required": True,
            "case_status": "unverified",
            "cross_source_match": "not_evaluated",
            "record_type": (
                "ncmec_missing_child_feed_record"
                if source == "ncmec"
                else "fbi_wanted_record"
            )
        })
        counts[source] += 1

unified.sort(
    key=lambda item: (
        item["source_id"],
        item["title"].lower(),
        item["global_id"]
    )
)

generated = datetime.now(timezone.utc).isoformat()

payload = {
    "schema_version": 1,
    "generated_at": generated,
    "description": "Unified source records, not verified unique cases",
    "automatic_sharing": False,
    "records": unified
}

report = {
    "generated_at": generated,
    "total_source_records": len(unified),
    "source_counts": dict(counts),
    "skipped": skipped,
    "verified_unique_missing_children": None,
    "cross_source_deduplication": "pending",
    "production_fbi_database_modified": False,
    "automatic_sharing": False
}

for path, data in [
    (output_path, payload),
    (report_path, report)
]:
    temp = path.with_suffix(".tmp")
    temp.write_text(
        json.dumps(data, ensure_ascii=False, indent=2),
        encoding="utf-8"
    )
    temp.replace(path)

print("=== IC391DEA UNIFIED DATABASE ===")
print("FBI RECORDS:", counts["fbi"])
print("NCMEC RECORDS:", counts["ncmec"])
print("TOTAL RECORDS:", len(unified))
print("SKIPPED:", skipped)
print("CROSS-SOURCE CASE MATCHING: PENDING")
print("FBI ORIGINAL: UNCHANGED")
print("NCMEC ORIGINAL: UNCHANGED")
print("AUTOMATIC SHARING: DISABLED")
print("OUTPUT:", output_path)

pubspec = Path("pubspec.yaml")
if pubspec.exists():
    print("")
    print("=== FLUTTER ASSET CONFIGURATION ===")
    for line in pubspec.read_text(encoding="utf-8").splitlines():
        if "assets:" in line or "data/fbi" in line or "data/intelligence" in line:
            print(line)

print("=== PHASE 10A COMPLETE ===")
