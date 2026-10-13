from pathlib import Path
import re
import json

p = Path("lib/screens/missing_children_screen.dart")
s = p.read_text(encoding="utf-8")
s = s.replace(chr(160), " ").replace(chr(8239), " ")

asset = Path(
    "data/intelligence/dashboard/unified_missing_children.json"
)

data = json.loads(asset.read_text(encoding="utf-8"))
records = data["records"]

if not isinstance(records, list):
    raise SystemExit("ERROR: Invalid records list")

if "selectedCategory" in s:
    print("CATEGORY FILTER: ALREADY INSTALLED")
    raise SystemExit(0)

anchor = "String selectedSource = 'ALL';"

if anchor not in s:
    raise SystemExit("ERROR: Source filter anchor missing")

s = s.replace(
    anchor,
    anchor + "\n  String selectedCategory = 'ALL INTELLIGENCE';",
    1,
)

helper = """
  static const intelligenceCategories = [
    'ALL INTELLIGENCE',
    'MISSING CHILDREN',
    'HUMAN TRAFFICKING',
    'MISSING PERSONS',
    'WANTED PERSONS',
    'INTERNATIONAL INTELLIGENCE',
    'FEDERAL INVESTIGATIONS',
    'ACTIVE ALERTS',
    'REVIEW REQUIRED',
  ];

  Set<String> classifyRecord(Map<String, dynamic> record) {
    final source =
        (record['source_id'] ?? '').toString().toLowerCase();
    final type =
        (record['record_type'] ?? '').toString().toLowerCase();
    final title =
        (record['title'] ?? '').toString().toLowerCase();
    final description =
        (record['description'] ?? '').toString().toLowerCase();

    final text = '$title $description';
    final categories = <String>{};

    final childTerms = RegExp(
      r'\\b(child|children|minor|juvenile|infant|baby|'
      r'toddler|missing girl|missing boy|amber alert)\\b',
    );

    final missingTerms = RegExp(
      r'\\b(missing|disappeared|abducted|kidnapped|'
      r'endangered|runaway)\\b',
    );

    final traffickingTerms = RegExp(
      r'\\b(human trafficking|sex trafficking|'
      r'child trafficking|labor trafficking)\\b',
    );

    if (source == 'ncmec' ||
        (childTerms.hasMatch(text) &&
            missingTerms.hasMatch(text))) {
      categories.add('MISSING CHILDREN');
    }

    if (traffickingTerms.hasMatch(text)) {
      categories.add('HUMAN TRAFFICKING');
    }

    if (missingTerms.hasMatch(text) ||
        type.contains('missing')) {
      categories.add('MISSING PERSONS');
    }

    if (source == 'fbi' ||
        source == 'us_marshals' ||
        type.contains('wanted')) {
      categories.add('WANTED PERSONS');
    }

    if (source == 'interpol') {
      categories.add('INTERNATIONAL INTELLIGENCE');
    }

    if (source == 'fbi' ||
        source == 'dhs' ||
        source == 'us_marshals') {
      categories.add('FEDERAL INVESTIGATIONS');
    }

    if (source == 'amber' ||
        text.contains('amber alert') ||
        type.contains('alert')) {
      categories.add('ACTIVE ALERTS');
    }

    if (categories.isEmpty ||
        record['review_required'] == true) {
      categories.add('REVIEW REQUIRED');
    }

    return categories;
  }

"""

marker = "  @override\n  void initState()"

if marker not in s:
    raise SystemExit("ERROR: initState anchor missing")

s = s.replace(marker, helper + marker, 1)

filter_anchor = """
      if (selectedSource != 'ALL' && source != selectedSource) {
        return false;
      }
"""

if filter_anchor not in s:
    raise SystemExit("ERROR: Source filtering anchor missing")

category_filter = """
      if (selectedCategory != 'ALL INTELLIGENCE' &&
          !classifyRecord(record).contains(selectedCategory)) {
        return false;
      }

"""

s = s.replace(
    filter_anchor,
    category_filter + filter_anchor,
    1,
)

search_anchor = """              Text('${results.length} matching source records'),"""

if search_anchor not in s:
    raise SystemExit("ERROR: Results counter anchor missing")

category_ui = """
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'INTELLIGENCE CATEGORY',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: intelligenceCategories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'Categories are preliminary automated classifications. '
                'Verify case details against the original source.',
                style: TextStyle(fontSize: 11),
              ),
"""

s = s.replace(
    search_anchor,
    category_ui + search_anchor,
    1,
)

detail_anchor = """              const SizedBox(height: 18),
              for (final field in ["""

if detail_anchor not in s:
    raise SystemExit("ERROR: Case details anchor missing")

detail_categories = """
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: classifyRecord(record).map((category) {
                  return Chip(label: Text(category));
                }).toList(),
              ),
              const SizedBox(height: 18),
              for (final field in ["""

s = s.replace(
    detail_anchor,
    detail_categories,
    1,
)

p.write_text(s, encoding="utf-8")

print("SOURCE RECORDS:", len(records))
print("INTELLIGENCE CATEGORIES:", 9)
print("CATEGORY FILTER: INSTALLED")
print("CASE DETAIL CATEGORY TAGS: INSTALLED")
print("SOURCE DATABASE: UNCHANGED")
print("AUTOMATIC SHARING: NOT ADDED")
