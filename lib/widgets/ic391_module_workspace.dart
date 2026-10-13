import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/genesis_theme.dart';

class IC391ModuleWorkspace extends StatefulWidget {
  final String title;
  final String subtitle;

  const IC391ModuleWorkspace({
    super.key,
    required this.title,
    this.subtitle = 'Intelligence operations workspace',
  });

  @override
  State<IC391ModuleWorkspace> createState() => _IC391ModuleWorkspaceState();
}

class _IC391ModuleWorkspaceState extends State<IC391ModuleWorkspace> {
  final noteController = TextEditingController();
  final searchController = TextEditingController();

  List<Map<String, dynamic>> items = [];
  String query = '';
  bool loaded = false;

  String get storageKey =>
      'ic391_module_${widget.title.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), "_")}';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);

    if (!mounted) return;

    setState(() {
      try {
        final decoded = jsonDecode(raw ?? '[]') as List;
        items =
            decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {
        items = [];
      }
      loaded = true;
    });
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode(items));
  }

  Future<void> addItem() async {
    final text = noteController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      items.insert(0, {
        'text': text,
        'done': false,
        'created': DateTime.now().toIso8601String(),
      });
      noteController.clear();
    });

    await save();
  }

  Future<void> toggleItem(int index) async {
    setState(() {
      items[index]['done'] = items[index]['done'] != true;
    });
    await save();
  }

  Future<void> deleteItem(int index) async {
    setState(() => items.removeAt(index));
    await save();
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    noteController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Widget panel({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(18),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF103565),
            Color(0xFF121F49),
            Color(0xFF240B42),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: GenesisColors.cyan,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3325EDFF),
            blurRadius: 15,
          ),
          BoxShadow(
            color: Color(0x33D43CFF),
            blurRadius: 18,
            offset: Offset(3, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = items
        .asMap()
        .entries
        .where((entry) => (entry.value['text'] ?? '')
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    return Container(
      color: GenesisColors.voidBlack,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.title.toUpperCase(),
            style: const TextStyle(
              color: GenesisColors.text,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.subtitle,
            style: const TextStyle(
              color: GenesisColors.cyan,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _metric('TOTAL ITEMS', '${items.length}', GenesisColors.cyan),
              _metric(
                'OPEN',
                '${items.where((e) => e['done'] != true).length}',
                GenesisColors.gold,
              ),
              _metric(
                'COMPLETED',
                '${items.where((e) => e['done'] == true).length}',
                GenesisColors.emerald,
              ),
            ],
          ),
          const SizedBox(height: 22),
          panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OPERATIONS WORKSPACE',
                  style: TextStyle(
                    color: GenesisColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'New operational note or task',
                    prefixIcon: Icon(Icons.edit_note),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('SAVE NEW ITEM'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: searchController,
            onChanged: (value) => setState(() => query = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search module items',
            ),
          ),
          const SizedBox(height: 18),
          if (!loaded)
            const Center(child: CircularProgressIndicator())
          else if (filtered.isEmpty)
            panel(
              child: const Text(
                'No matching records in this workspace.',
                style: TextStyle(color: GenesisColors.muted),
              ),
            )
          else
            for (final entry in filtered)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: panel(
                  child: Row(
                    children: [
                      Checkbox(
                        value: entry.value['done'] == true,
                        onChanged: (_) => toggleItem(entry.key),
                      ),
                      Expanded(
                        child: Text(
                          entry.value['text'].toString(),
                          style: TextStyle(
                            color: GenesisColors.text,
                            decoration: entry.value['done'] == true
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete item',
                        onPressed: () => deleteItem(entry.key),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: GenesisColors.pink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, Color accent) {
    return SizedBox(
      width: 190,
      child: panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                  color: GenesisColors.muted,
                  fontSize: 11,
                )),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: accent,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
