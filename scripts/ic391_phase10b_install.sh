#!/bin/bash

cd "/Volumes/Extreme SSD/999 Projects/Apps/IC391DEA" || exit 1

SCREEN="lib/screens/missing_children_screen.dart"
PUBSPEC="pubspec.yaml"
ASSET="data/intelligence/dashboard/unified_missing_children.json"
STAMP=$(date +%Y%m%d_%H%M%S)

echo "=== IC391DEA PHASE 10B INSTALL ==="

if [ ! -s "$ASSET" ]; then
  echo "ERROR: Unified database missing"
  exit 1
fi

if [ ! -f "$SCREEN" ] || [ ! -f "$PUBSPEC" ]; then
  echo "ERROR: Flutter files missing"
  exit 1
fi

cp "$SCREEN" "$SCREEN.backup_$STAMP"
cp "$PUBSPEC" "$PUBSPEC.backup_$STAMP"

echo "BACKUPS: CREATED"

cat > "$SCREEN" <<'DART'
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MissingChildrenScreen extends StatefulWidget {
  const MissingChildrenScreen({super.key});

  @override
  State<MissingChildrenScreen> createState() =>
      _MissingChildrenScreenState();
}

class _MissingChildrenScreenState extends State<MissingChildrenScreen> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> records = [];
  bool loading = true;
  String? error;
  String query = '';
  String selectedSource = 'ALL';
  String selectedState = 'ALL';

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {
    try {
      final content = await rootBundle.loadString(
        'data/intelligence/dashboard/unified_missing_children.json',
      );

      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final items = decoded['records'] as List<dynamic>;

      if (!mounted) return;

      setState(() {
        records = items
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String display(dynamic value) {
    if (value == null) return 'Not provided';
    if (value is List) return value.join(', ');
    final result = value.toString().trim();
    return result.isEmpty ? 'Not provided' : result;
  }

  Future<void> openSource(Map<String, dynamic> record) async {
    final raw = record['source_url']?.toString() ?? '';
    final parsed = Uri.tryParse(raw);
    if (parsed == null) return;

    final host = parsed.host.toLowerCase();
    final trusted = host == 'fbi.gov' ||
        host.endsWith('.fbi.gov') ||
        host == 'missingkids.org' ||
        host.endsWith('.missingkids.org');

    if (!trusted) return;
    if (parsed.scheme != 'http' && parsed.scheme != 'https') return;

    final uri = parsed.replace(scheme: 'https');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void showDetails(Map<String, dynamic> record) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.85,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                display(record['title']),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'PUBLIC SOURCE RECORD - REVIEW REQUIRED',
                style: TextStyle(color: Colors.amberAccent),
              ),
              const SizedBox(height: 18),
              for (final field in [
                'source_id',
                'source_record_id',
                'state',
                'subjects',
                'description',
                'published',
                'case_status',
                'cross_source_match',
              ]) ...[
                Text(
                  field.toUpperCase().replaceAll('_', ' '),
                  style: const TextStyle(
                    color: Colors.tealAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                SelectableText(display(record[field])),
                const SizedBox(height: 15),
              ],
              FilledButton.icon(
                onPressed: () => openSource(record),
                icon: const Icon(Icons.open_in_new),
                label: const Text('OPEN OFFICIAL SOURCE'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: SelectableText('DATABASE ERROR: $error'),
      );
    }

    final sources = records
        .map((r) => display(r['source_id']).toUpperCase())
        .toSet()
        .toList()
      ..sort();

    final states = records
        .map((r) => display(r['state']).toUpperCase())
        .where((s) => RegExp(r'^[A-Z]{2}$').hasMatch(s))
        .toSet()
        .toList()
      ..sort();

    final search = query.trim().toLowerCase();

    final results = records.where((record) {
      final source = display(record['source_id']).toUpperCase();
      final state = display(record['state']).toUpperCase();

      if (selectedSource != 'ALL' && source != selectedSource) {
        return false;
      }

      if (selectedState != 'ALL' && state != selectedState) {
        return false;
      }

      if (search.isEmpty) return true;

      final searchable = [
        record['title'],
        record['description'],
        record['state'],
        record['subjects'],
        record['source_record_id'],
        record['source_id'],
      ].map(display).join(' ').toLowerCase();

      return searchable.contains(search);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'IC391DEA | MISSING CHILDREN INTELLIGENCE',
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('${records.length} unified source records'),
              const SizedBox(height: 5),
              const Text(
                'One intelligence database. Records are not '
                'verified unique missing-child cases. '
                'Snapshot only; no live synchronization.',
                style: TextStyle(fontSize: 11),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() => query = value);
                },
                decoration: const InputDecoration(
                  hintText: 'Search all intelligence records',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedSource,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'SOURCE',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'ALL',
                        ...sources,
                      ].map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item == 'ALL' ? 'ALL SOURCES' : item,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedSource = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedState,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'STATE',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'ALL',
                        ...states,
                      ].map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item == 'ALL' ? 'ALL STATES' : item,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedState = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text('${results.length} matching source records'),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final record = results[index];
              final agency =
                  display(record['source_id']).toUpperCase();

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                child: ListTile(
                  leading: Icon(
                    agency == 'NCMEC'
                        ? Icons.child_care_outlined
                        : Icons.folder_shared_outlined,
                    color: Colors.tealAccent,
                  ),
                  title: Text(display(record['title'])),
                  subtitle: Text(
                    '$agency | ${display(record['state'])}\n'
                    'REVIEW REQUIRED',
                    maxLines: 2,
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showDetails(record),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
DART

# Register the unified JSON under the existing Flutter assets section.
if ! grep -Fq -- "- $ASSET" "$PUBSPEC"; then
  sed -i '' "/^[[:space:]]*assets:[[:space:]]*$/a\\
    - $ASSET
" "$PUBSPEC"
fi

echo "SCREEN: UPDATED"
echo "ASSET: REGISTERED"

dart format "$SCREEN" || exit 1
flutter pub get || exit 1
flutter analyze --no-pub "$SCREEN"
analyze_result=$?

if [ "$analyze_result" -ne 0 ]; then
  echo "=== PHASE 10B NEEDS REVIEW ==="
  exit "$analyze_result"
fi

echo "=== PHASE 10B VERIFIED ==="
