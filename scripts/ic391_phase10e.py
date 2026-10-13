from pathlib import Path
import json
import re
import html
import shutil

root = Path("data/intelligence")
unified_path = root / "dashboard/unified_missing_children.json"
fbi_path = Path("data/fbi/fbi_wanted_records.json")
ncmec_path = root / "staging/ncmec_records.json"
output_path = root / "dashboard/unified_enriched_records.json"
screen_path = Path("lib/screens/missing_children_screen.dart")
pubspec_path = Path("pubspec.yaml")

def load_records(path):
    obj = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(obj, list):
        return obj
    if isinstance(obj, dict):
        if isinstance(obj.get("records"), list):
            return obj["records"]
        for value in obj.values():
            if isinstance(value, list):
                return value
    raise ValueError("No record list in " + str(path))

unified = load_records(unified_path)
fbi = load_records(fbi_path)
ncmec = load_records(ncmec_path)

fbi_by_uid = {
    str(item.get("uid")): item
    for item in fbi
    if isinstance(item, dict) and item.get("uid")
}

fbi_by_url = {
    str(item.get("url", "")).rstrip("/"): item
    for item in fbi
    if isinstance(item, dict) and item.get("url")
}

ncmec_by_id = {
    str(item.get("source_record_id")): item
    for item in ncmec
    if isinstance(item, dict) and item.get("source_record_id")
}

ncmec_by_url = {
    str(item.get("source_url", "")).replace("http://", "https://"): item
    for item in ncmec
    if isinstance(item, dict) and item.get("source_url")
}

def text_value(value):
    if value is None:
        return ""
    if isinstance(value, list):
        return " ".join(str(x) for x in value)
    return str(value)

def categorize(record, original):
    source = text_value(record.get("source_id")).lower()
    title = text_value(record.get("title")).lower()
    description = text_value(record.get("description")).lower()
    subjects = text_value(original.get("subjects")).lower()
    path = text_value(original.get("path")).lower()
    poster = text_value(original.get("poster_classification")).lower()
    combined = " ".join([title, description, subjects, path])
    categories = set()

    if source == "ncmec":
        categories.add("MISSING CHILDREN")

    if re.search(r"\b(child|children|minor|juvenile|infant|baby)\b", combined):
        if re.search(r"\b(missing|abducted|kidnapped|endangered)\b", combined):
            categories.add("MISSING CHILDREN")

    if "trafficking" in combined:
        categories.add("HUMAN TRAFFICKING")

    if "missing" in combined:
        categories.add("MISSING PERSONS")

    if source == "interpol":
        categories.add("INTERNATIONAL INTELLIGENCE")

    if source in ("fbi", "dhs", "us_marshals"):
        categories.add("FEDERAL INVESTIGATIONS")

    wanted_indicators = (
        "wanted" in subjects
        or "/wanted/topten/" in path
        or "/wanted/fugitives/" in path
        or poster == "wanted"
    )

    if wanted_indicators:
        categories.add("WANTED PERSONS")

    if source == "amber" or "amber alert" in combined:
        categories.add("ACTIVE ALERTS")

    if not categories:
        categories.add("REVIEW REQUIRED")

    return sorted(categories)

enriched = []
fbi_matches = 0
ncmec_matches = 0
unmatched = 0

for record in unified:
    if not isinstance(record, dict):
        continue

    item = dict(record)
    source = text_value(item.get("source_id")).lower()
    record_id = text_value(item.get("source_record_id"))
    source_url = text_value(item.get("source_url"))

    original = None

    if source == "fbi":
        original = fbi_by_uid.get(record_id)
        if original is None:
            original = fbi_by_url.get(source_url.rstrip("/"))
        if original is not None:
            fbi_matches += 1

    elif source == "ncmec":
        original = ncmec_by_id.get(record_id)
        if original is None:
            original = ncmec_by_url.get(
                source_url.replace("http://", "https://")
            )
        if original is not None:
            ncmec_matches += 1

    if original is None:
        unmatched += 1
        original = {}

    item["source_details"] = original
    item["intelligence_categories"] = categorize(item, original)
    item["source_enriched"] = bool(original)
    enriched.append(item)

if len(enriched) != len(unified):
    raise SystemExit("ERROR: Record count changed")

payload = {
    "schema_version": "10E",
    "record_count": len(enriched),
    "source_note": "Public source snapshots; case status requires verification",
    "records": enriched,
}

output_path.write_text(
    json.dumps(payload, ensure_ascii=False, indent=2),
    encoding="utf-8",
)

s = screen_path.read_text(encoding="utf-8")
s = s.replace(chr(160), " ").replace(chr(8239), " ")

s = s.replace(
    "data/intelligence/dashboard/unified_missing_children.json",
    "data/intelligence/dashboard/unified_enriched_records.json",
)

start = s.find("  Set<String> classifyRecord(Map<String, dynamic> record) {")
end = s.find("  @override\n  void initState()", start)

if start < 0 or end < 0:
    raise SystemExit("ERROR: Classification function not found")

classification = """
  Set<String> classifyRecord(Map<String, dynamic> record) {
    final categories = record['intelligence_categories'];
    if (categories is List) {
      return categories.map((e) => e.toString()).toSet();
    }
    return {'REVIEW REQUIRED'};
  }

"""

s = s[:start] + classification + s[end:]

anchor = "  void showDetails(Map<String, dynamic> record) {"

if anchor not in s:
    raise SystemExit("ERROR: Case details function not found")

helpers = """
  Widget sourcePhoto(Map<String, dynamic> record) {
    final details = record['source_details'];
    if (details is! Map) return const SizedBox.shrink();

    final images = details['images'];
    if (images is! List || images.isEmpty) {
      return const SizedBox.shrink();
    }

    final urls = <String>[];

    for (final image in images) {
      if (image is Map) {
        final url = (image['large'] ??
                image['original'] ??
                image['thumb'])
            ?.toString();

        if (url != null &&
            Uri.tryParse(url)?.scheme == 'https') {
          urls.add(url);
        }
      }
    }

    if (urls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OFFICIAL SOURCE IMAGES',
          style: TextStyle(
            color: Colors.tealAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: urls.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  urls[index],
                  width: 170,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const SizedBox(
                    width: 170,
                    child: Center(
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget fullSourceFields(Map<String, dynamic> record) {
    final raw = record['source_details'];

    if (raw is! Map || raw.isEmpty) {
      return const Text('Full source details not available.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COMPLETE ORIGINAL SOURCE DATA',
          style: TextStyle(
            color: Colors.tealAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
        for (final entry in raw.entries)
          intelligenceField(
            entry.key.toString(),
            entry.value is Map || entry.value is List
                ? const JsonEncoder.withIndent('  ')
                    .convert(entry.value)
                : entry.value,
          ),
      ],
    );
  }

"""

s = s.replace(anchor, helpers + anchor, 1)

details_anchor = """                    const SizedBox(height: 22),
                    const Text(
                      'CASE IDENTIFICATION',"""

if details_anchor not in s:
    raise SystemExit("ERROR: Case identification anchor missing")

s = s.replace(
    details_anchor,
    """                    sourcePhoto(record),
""" + details_anchor,
    1,
)

source_anchor = """                    const SizedBox(height: 22),
                    const Text(
                      'CROSS-SOURCE INTELLIGENCE',"""

if source_anchor not in s:
    raise SystemExit("ERROR: Cross-source anchor missing")

s = s.replace(
    source_anchor,
    """                    const SizedBox(height: 22),
                    fullSourceFields(record),
""" + source_anchor,
    1,
)

screen_path.write_text(s, encoding="utf-8")

pubspec = pubspec_path.read_text(encoding="utf-8")
asset_line = "- data/intelligence/dashboard/unified_enriched_records.json"

if asset_line not in pubspec:
    lines = pubspec.splitlines()
    for index, line in enumerate(lines):
        if line.strip() == "assets:":
            indentation = len(line) - len(line.lstrip())
            lines.insert(
                index + 1,
                " " * (indentation + 2) + asset_line,
            )
            break
    else:
        raise SystemExit("ERROR: Flutter assets section missing")

    pubspec_path.write_text(
        "\n".join(lines) + "\n",
        encoding="utf-8",
    )

print("UNIFIED RECORDS:", len(enriched))
print("FBI FULL RECORD MATCHES:", fbi_matches)
print("NCMEC FULL RECORD MATCHES:", ncmec_matches)
print("UNMATCHED SOURCE RECORDS:", unmatched)
print("FULL SOURCE DETAILS: ENABLED")
print("OFFICIAL FBI IMAGES: ENABLED")
print("CATEGORY REFINEMENT: ENABLED")
print("ORIGINAL SOURCE FILES: UNCHANGED")
print("AUTOMATIC SHARING: DISABLED")
