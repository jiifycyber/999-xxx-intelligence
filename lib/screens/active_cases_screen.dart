import '../core/genesis_theme.dart';
import '../widgets/ic391_master_panel.dart';
import 'package:flutter/material.dart';
import '../services/ic391_case_store.dart';
import '../widgets/ic391_premium_shell.dart';

class ActiveCasesScreen extends StatefulWidget {
  const ActiveCasesScreen({super.key});

  @override
  State<ActiveCasesScreen> createState() => _ActiveCasesScreenState();
}

class _ActiveCasesScreenState extends State<ActiveCasesScreen> {
  List<Map<String, dynamic>> cases = [];
  bool loading = true;
  String query = '';

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    final result = await Ic391CaseStore.load();
    if (!mounted) return;
    setState(() {
      cases = result;
      loading = false;
    });
  }

  Future<void> openCase(Map<String, dynamic> item) async {
    final controller = TextEditingController(
      text: item['notes']?.toString() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => IC391PremiumShell(
          child: AlertDialog(
        backgroundColor: GenesisColors.midnight,
        title: Text(
          item['title']?.toString() ?? 'Case file',
          style: const TextStyle(color: GenesisColors.text),
        ),
        content: SizedBox(
          width: 580,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRIVATE INTERNAL REVIEW - NOT AN OFFICIAL CASE STATUS',
                  style: TextStyle(color: GenesisColors.warning),
                ),
                const SizedBox(height: 14),
                Text(
                  'Source: ${item['source_id']}',
                  style: const TextStyle(color: GenesisColors.muted),
                ),
                const SizedBox(height: 10),
                Text(
                  'Opened: ${item['opened_at']}',
                  style: const TextStyle(color: GenesisColors.muted),
                ),
                const SizedBox(height: 18),
                const Text(
                  'PRIVATE CASE NOTES',
                  style: TextStyle(color: GenesisColors.cyan),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  maxLines: 8,
                  style: const TextStyle(color: GenesisColors.text),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Record observations and review notes',
                    hintStyle: TextStyle(color: GenesisColors.muted),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () async {
              final next = cases
                  .map((entry) => Map<String, dynamic>.from(entry))
                  .toList();

              final index = next.indexWhere(
                (entry) => entry['global_id'] == item['global_id'],
              );

              if (index < 0) return;

              next[index]['notes'] = controller.text;

              try {
                await Ic391CaseStore.save(next);
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                await refresh();
              } catch (error) {
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('Save failed: $error')),
                );
              }
            },
            child: const Text('SAVE NOTES'),
          ),
        ],
      )),
    );

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = cases.where((item) {
      final title = item['title']?.toString().toLowerCase() ?? '';
      return title.contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: GenesisColors.voidBlack,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'IC391DEA | ACTIVE CASE OPERATIONS',
              style: TextStyle(
                color: GenesisColors.cyan,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Private internal review queue. Imported public records are not automatically active cases.',
              style: TextStyle(color: GenesisColors.muted),
            ),
            const SizedBox(height: 20),
            IC391MasterPanel(
              color: GenesisColors.panelRaised,
              child: ListTile(
                title: Text(
                  '${cases.length} OPENED CASES',
                  style: const TextStyle(
                    color: GenesisColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Locally stored in this browser profile',
                  style: TextStyle(color: GenesisColors.muted),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh, color: GenesisColors.cyan),
                  onPressed: refresh,
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              onChanged: (value) => setState(() => query = value),
              style: const TextStyle(color: GenesisColors.text),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search active case files',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'No cases opened yet. Select a record in Missing Children to begin a private review.',
                            style: TextStyle(color: GenesisColors.muted),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return IC391MasterPanel(
                              color: GenesisColors.panelRaised,
                              child: ListTile(
                                leading: const Icon(
                                  Icons.folder_shared_outlined,
                                  color: GenesisColors.cyan,
                                ),
                                title: Text(
                                  item['title']?.toString() ?? '',
                                  style: const TextStyle(
                                      color: GenesisColors.text),
                                ),
                                subtitle: Text(
                                  '${item['source_id']} | OPEN FOR REVIEW',
                                  style: const TextStyle(
                                      color: GenesisColors.muted),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: GenesisColors.muted,
                                ),
                                onTap: () => openCase(item),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
