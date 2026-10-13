import json
from pathlib import Path
from collections import Counter
from urllib.parse import urlparse

root = Path("data/intelligence/staging")
source = root / "ncmec_records.json"
report = root / "ncmec_validation_report.json"

print("=== IC391DEA NCMEC VALIDATION ===")

if not source.exists():
    raise SystemExit("ERROR: NCMEC staging file missing.")

data = json.loads(source.read_text(encoding="utf-8"))
records = data.get("records", [])

if not isinstance(records, list):
    raise SystemExit("ERROR: Invalid records format.")

feeds = Counter()
domains = Counter()
ids = Counter()
missing_links = 0
missing_feeds = 0

for record in records:
    if not isinstance(record, dict):
        continue

    uid = str(record.get("global_id") or "")
    ids[uid] += 1

    details = record.get("details") or {}
    feed = str(details.get("feed_url") or "")
    link = str(record.get("source_url") or "")

    if feed:
        feeds[feed] += 1
    else:
        missing_feeds += 1

    if link:
        domains[urlparse(link).hostname or "unknown"] += 1
    else:
        missing_links += 1

duplicates = sum(
    count - 1 for count in ids.values()
    if count > 1
)

summary = {
    "total_records": len(records),
    "unique_identifiers": len(ids),
    "duplicate_identifiers": duplicates,
    "missing_source_links": missing_links,
    "missing_feed_urls": missing_feeds,
    "feed_counts": dict(feeds),
    "source_domains": dict(domains),
    "verified_missing_child_cases": None,
    "production_database_modified": False
}

report.write_text(
    json.dumps(summary, indent=2),
    encoding="utf-8"
)

print("TOTAL RECORDS:", len(records))
print("UNIQUE IDENTIFIERS:", len(ids))
print("DUPLICATES:", duplicates)
print("MISSING SOURCE LINKS:", missing_links)
print("MISSING FEED URLS:", missing_feeds)

print("\n=== SOURCE DOMAINS ===")
for domain, count in domains.most_common():
    print(domain, count)

print("\n=== FEED COUNTS ===")
for feed, count in feeds.most_common():
    print(count, feed)

print("\nVERIFIED CHILD CASES: NOT YET DETERMINED")
print("FBI DATABASE: UNCHANGED")
print("REPORT:", report)
print("VALIDATION COMPLETE")
