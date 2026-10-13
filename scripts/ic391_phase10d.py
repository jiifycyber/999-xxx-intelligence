from pathlib import Path
import re

p = Path("lib/screens/missing_children_screen.dart")
s = p.read_text(encoding="utf-8")
s = s.replace(chr(160), " ").replace(chr(8239), " ")

start = s.find("  void showDetails(Map<String, dynamic> record) {")
end = s.find("  @override\n  Widget build(BuildContext context)", start)

if start < 0 or end < 0:
    raise SystemExit("ERROR: Case detail section not found")

replacement = """
  Widget intelligenceField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.tealAccent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          SelectableText(display(value)),
        ],
      ),
    );
  }

  void showDetails(Map<String, dynamic> record) {
    final categories = classifyRecord(record).toList()..sort();

    final fields = <String, dynamic>{
      'Source agency': record['source_id'],
      'Source record ID': record['source_record_id'],
      'Global record ID': record['global_id'],
      'Record type': record['record_type'],
      'State / location': record['state'],
      'Subjects': record['subjects'],
      'Published date': record['published'],
      'Case status': record['case_status'],
      'Cross-source matching': record['cross_source_match'],
      'Review required': record['review_required'],
    };

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101C32),
      builder: (context) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.92,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF172A48),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.folder_shared_outlined,
                      color: Colors.tealAccent,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'IC391DEA | INTELLIGENCE CASE FILE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Text(
                      display(record['title']),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'PUBLIC INTELLIGENCE RECORD - NOT VERIFIED',
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: categories.map((category) {
                        return Chip(
                          label: Text(category),
                          backgroundColor: const Color(0xFF203A59),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'CASE IDENTIFICATION',
                      style: TextStyle(
                        color: Colors.tealAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    for (final entry in fields.entries)
                      intelligenceField(entry.key, entry.value),
                    const SizedBox(height: 12),
                    const Text(
                      'OFFICIAL SOURCE DESCRIPTION',
                      style: TextStyle(
                        color: Colors.tealAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    SelectableText(
                      display(record['description']),
                      style: const TextStyle(height: 1.5),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'CROSS-SOURCE INTELLIGENCE',
                      style: TextStyle(
                        color: Colors.tealAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const Text(
                      'Potential related records have not been '
                      'evaluated. No confirmed connection is implied.',
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'PRIVATE INVESTIGATION VAULT',
                      style: TextStyle(
                        color: Colors.tealAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const Text(
                      'Private notes and evidence management '
                      'will be connected in a future phase. '
                      'No automatic evidence sharing is enabled.',
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => openSource(record),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('OPEN OFFICIAL SOURCE'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

"""

s = s[:start] + replacement + s[end:]
p.write_text(s, encoding="utf-8")

print("ADVANCED CASE FILE: INSTALLED")
print("CASE IDENTIFICATION: ENABLED")
print("CATEGORY TAGS: PRESERVED")
print("SOURCE DESCRIPTION: ENABLED")
print("CROSS-SOURCE STATUS: DISPLAYED")
print("PRIVATE VAULT: PLACEHOLDER ONLY")
print("AUTOMATIC SHARING: DISABLED")
