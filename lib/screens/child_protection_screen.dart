import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/genesis_theme.dart';

class ChildProtectionScreen extends StatefulWidget {
  const ChildProtectionScreen({super.key});

  @override
  State<ChildProtectionScreen> createState() => _ChildProtectionScreenState();
}

class _ChildProtectionScreenState extends State<ChildProtectionScreen> {
  static const storageKey = 'ic391_child_protection_stage5_v1';

  final search = TextEditingController();
  final name = TextEditingController();
  final details = TextEditingController();

  List<Map<String, dynamic>> records = [];
  String filter = 'All';
  int tab = 0;
  bool loading = true;

  static const tabs = [
    'Overview',
    'Risk Assessments',
    'Protective Services',
    'Interventions',
    'Resources',
    'Reports',
  ];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    List<Map<String, dynamic>> loaded = [];

    if (raw != null) {
      try {
        final value = jsonDecode(raw) as List;
        loaded = value.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      records = loaded;
      loading = false;
    });
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode(records));
  }

  Future<void> createRecord() async {
    name.clear();
    details.clear();
    String risk = 'Unassessed';

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          backgroundColor: GenesisColors.midnight,
          title: const Text('New Safeguarding Record'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Use a reference ID rather than a child’s name. '
                    'Local browser storage is not an approved '
                    'sensitive-evidence vault.',
                    style: TextStyle(
                      color: GenesisColors.gold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(
                      labelText: 'Record reference ID',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: risk,
                    decoration: const InputDecoration(
                      labelText: 'Assessment priority',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Unassessed',
                        child: Text('Unassessed'),
                      ),
                      DropdownMenuItem(
                        value: 'Low',
                        child: Text('Low'),
                      ),
                      DropdownMenuItem(
                        value: 'Moderate',
                        child: Text('Moderate'),
                      ),
                      DropdownMenuItem(
                        value: 'High',
                        child: Text('High'),
                      ),
                    ],
                    onChanged: (v) => update(() => risk = v ?? 'Unassessed'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: details,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Non-sensitive operational note',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result != true || name.text.trim().isEmpty) return;

    setState(() {
      records.insert(0, {
        'id': '${DateTime.now().microsecondsSinceEpoch}',
        'name': name.text.trim(),
        'risk': risk,
        'note': details.text.trim(),
        'status': 'Open',
        'created': DateTime.now().toIso8601String(),
      });
    });

    await save();
  }

  Future<void> changeStatus(int index, String status) async {
    setState(() => records[index]['status'] = status);
    await save();
  }

  Future<void> removeRecord(int index) async {
    setState(() => records.removeAt(index));
    await save();
  }

  @override
  void dispose() {
    search.dispose();
    name.dispose();
    details.dispose();
    super.dispose();
  }

  Widget panel(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B2A50),
            Color(0xFF10183A),
            Color(0xFF210D40),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: GenesisColors.cyan.withValues(alpha: .65),
        ),
        boxShadow: [
          BoxShadow(
            color: GenesisColors.purple.withValues(alpha: .16),
            blurRadius: 16,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget metric(String label, int value, IconData icon, Color color) {
    return SizedBox(
      width: 205,
      child: panel(
        Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: TextStyle(
                      color: color,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      color: GenesisColors.text,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget heading(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          style: const TextStyle(
            color: GenesisColors.gold,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      );

  Widget _stage6InsightPanel() {
    final total = records.length;
    final high = records.where((r) => r['risk'] == 'High').length;
    final moderate = records.where((r) => r['risk'] == 'Moderate').length;
    final low = records.where((r) => r['risk'] == 'Low').length;
    final unassessed = records.where((r) => r['risk'] == 'Unassessed').length;
    final review = records.where((r) => r['status'] == 'In Review').length;
    final closed = records.where((r) => r['status'] == 'Closed').length;
    final open = records.where((r) => r['status'] == 'Open').length;
    Widget metric(String label, int value, IconData icon, Color color) =>
        Container(
            width: 168,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF0A2448), Color(0xFF26104B)]),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: color.withValues(alpha: .75)),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: .14), blurRadius: 14)
                ]),
            child: Row(children: [
              Icon(icon, color: color, size: 25),
              const SizedBox(width: 9),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('$value',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900)),
                    Text(label,
                        style: const TextStyle(
                            color: GenesisColors.muted, fontSize: 10)),
                  ]))
            ]));
    Widget distribution(String title, List<(String, int, Color)> values) =>
        Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF0A2448), Color(0xFF210D3D)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GenesisColors.border)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                      color: GenesisColors.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              for (final item in values)
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(children: [
                      SizedBox(
                          width: 88,
                          child: Text(item.$1,
                              style: const TextStyle(
                                  color: GenesisColors.text, fontSize: 11))),
                      Expanded(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                  value: total == 0 ? 0 : item.$2 / total,
                                  minHeight: 11,
                                  backgroundColor: GenesisColors.panelRaised,
                                  color: item.$3))),
                      const SizedBox(width: 10),
                      Text('${item.$2}',
                          style: const TextStyle(color: GenesisColors.text))
                    ]))
            ]));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('LOCAL SAFEGUARDING INTELLIGENCE',
          style: TextStyle(
              color: GenesisColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1)),
      const SizedBox(height: 12),
      Wrap(spacing: 10, runSpacing: 10, children: [
        metric('ALL RECORDS', total, Icons.people_outline, GenesisColors.cyan),
        metric('HIGH PRIORITY', high, Icons.warning_amber, GenesisColors.pink),
        metric('UNASSESSED', unassessed, Icons.visibility_outlined,
            GenesisColors.gold),
        metric('IN REVIEW', review, Icons.manage_search,
            GenesisColors.purpleBright),
        metric('OPEN', open, Icons.folder_open, GenesisColors.cyan),
        metric(
            'CLOSED', closed, Icons.verified_outlined, GenesisColors.emerald),
      ]),
      const SizedBox(height: 14),
      LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth > 760;
        final width = wide ? (c.maxWidth - 12) / 2 : c.maxWidth;
        return Wrap(spacing: 12, runSpacing: 12, children: [
          SizedBox(
              width: width,
              child: distribution('RISK LEVEL DISTRIBUTION', [
                ('High', high, GenesisColors.pink),
                ('Moderate', moderate, GenesisColors.gold),
                ('Low', low, GenesisColors.cyan),
                ('Unassessed', unassessed, GenesisColors.muted)
              ])),
          SizedBox(
              width: width,
              child: distribution('CASE WORKFLOW STATUS', [
                ('Open', open, GenesisColors.gold),
                ('In Review', review, GenesisColors.cyan),
                ('Closed', closed, GenesisColors.emerald)
              ])),
        ]);
      }),
      const SizedBox(height: 14),
      Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: GenesisColors.panelRaised,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: GenesisColors.border)),
          child: const Text(
              'DATA INTEGRITY: All metrics use locally saved safeguarding records. No simulated child profiles, live agency alerts, or verified recovery outcomes.',
              style: TextStyle(color: GenesisColors.muted, fontSize: 11))),
    ]);
  }

  Widget _stage7QuickActions() {
    Widget action(
      String title,
      String subtitle,
      IconData icon,
      Color accent,
      VoidCallback onPressed,
    ) {
      return SizedBox(
        width: 235,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0A2448),
                    Color(0xFF210D3D),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accent.withValues(alpha: .75),
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: .12),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: accent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: GenesisColors.text,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: GenesisColors.muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading('OPERATIONAL QUICK ACTIONS'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            action(
              'CREATE SAFEGUARDING RECORD',
              'Start a local case assessment',
              Icons.assignment_add,
              GenesisColors.cyan,
              createRecord,
            ),
            action(
              'RISK ASSESSMENTS',
              'Open assessment workspace',
              Icons.analytics_outlined,
              GenesisColors.pink,
              () => setState(() => tab = 1),
            ),
            action(
              'PROTECTIVE SERVICES',
              'Open service coordination',
              Icons.health_and_safety,
              GenesisColors.emerald,
              () => setState(() => tab = 2),
            ),
            action(
              'INTERVENTIONS',
              'Open intervention workspace',
              Icons.handshake,
              GenesisColors.gold,
              () => setState(() => tab = 3),
            ),
            action(
              'SUPPORT RESOURCES',
              'Open available resources',
              Icons.support_agent,
              GenesisColors.purpleBright,
              () => setState(() => tab = 4),
            ),
            action(
              'REPORTS',
              'Open safeguarding reports',
              Icons.description_outlined,
              GenesisColors.cyan,
              () => setState(() => tab = 5),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = records.asMap().entries.where((entry) {
      final record = entry.value;
      final matchesText = [
        record['name'],
        record['risk'],
        record['status'],
        record['note'],
      ].join(' ').toLowerCase().contains(search.text.toLowerCase());

      return matchesText && (filter == 'All' || record['risk'] == filter);
    }).toList();

    final high = records.where((r) => r['risk'] == 'High').length;
    final open = records.where((r) => r['status'] == 'Open').length;
    final closed = records.where((r) => r['status'] == 'Closed').length;

    return Container(
      color: GenesisColors.voidBlack,
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 16,
                  runSpacing: 14,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHILD PROTECTION',
                          style: TextStyle(
                            color: GenesisColors.text,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'SAFEGUARDING • RISK ASSESSMENT • INTERVENTION',
                          style: TextStyle(
                            color: GenesisColors.cyan,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    FilledButton.icon(
                      onPressed: createRecord,
                      icon: const Icon(Icons.add),
                      label: const Text('NEW RECORD'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < tabs.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(tabs[i]),
                            selected: tab == i,
                            onSelected: (_) => setState(() => tab = i),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (tab == 0) ...[
                  _stage6InsightPanel(),
                  const SizedBox(height: 18),
                  _stage7QuickActions(),
                  const SizedBox(height: 18),
                ],
                panel(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heading(tabs[tab].toUpperCase()),
                      const Text(
                        'Local safeguarding workflow. '
                        'No live agency feed or verified national '
                        'case count is connected to this module.',
                        style: TextStyle(
                          color: GenesisColors.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          OutlinedButton.icon(
                            onPressed: createRecord,
                            icon: const Icon(Icons.assignment_add),
                            label: const Text('Create Assessment'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => setState(() => tab = 2),
                            icon: const Icon(Icons.health_and_safety),
                            label: const Text('Protective Services'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => setState(() => tab = 3),
                            icon: const Icon(Icons.handshake),
                            label: const Text('Interventions'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                panel(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heading('SAFEGUARDING RECORDS'),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: 340,
                            child: TextField(
                              controller: search,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                hintText: 'Search local records',
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 175,
                            child: DropdownButtonFormField<String>(
                              initialValue: filter,
                              items: const [
                                'All',
                                'Unassessed',
                                'Low',
                                'Moderate',
                                'High',
                              ]
                                  .map((v) => DropdownMenuItem(
                                        value: v,
                                        child: Text(v),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => filter = v ?? 'All'),
                              decoration: const InputDecoration(
                                labelText: 'Risk level',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (visible.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'No matching safeguarding records. '
                            'Create a record to begin.',
                            style: TextStyle(
                              color: GenesisColors.muted,
                            ),
                          ),
                        ),
                      for (final entry in visible)
                        Card(
                          color: GenesisColors.panelRaised,
                          child: ListTile(
                            leading: const Icon(
                              Icons.shield,
                              color: GenesisColors.cyan,
                            ),
                            title: Text(
                              entry.value['name'].toString(),
                            ),
                            subtitle: Text(
                              'Priority: ${entry.value['risk']}'
                              '  •  ${entry.value['status']}'
                              '\n${entry.value['note']}',
                            ),
                            isThreeLine: true,
                            trailing: PopupMenuButton<String>(
                              tooltip: 'Record actions',
                              onSelected: (action) {
                                if (action == 'Delete') {
                                  removeRecord(entry.key);
                                } else {
                                  changeStatus(entry.key, action);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'Open',
                                  child: Text('Mark Open'),
                                ),
                                PopupMenuItem(
                                  value: 'In Review',
                                  child: Text('Mark In Review'),
                                ),
                                PopupMenuItem(
                                  value: 'Closed',
                                  child: Text('Mark Closed'),
                                ),
                                PopupMenuItem(
                                  value: 'Delete',
                                  child: Text('Delete Record'),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                panel(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heading('OPERATIONAL SAFETY'),
                      const Text(
                        'For immediate danger, contact emergency '
                        'services. This workspace does not dispatch '
                        'responders or automatically report cases.',
                        style: TextStyle(
                          color: GenesisColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
