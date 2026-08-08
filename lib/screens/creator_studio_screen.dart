import 'package:flutter/material.dart';
import '../widgets/markeela_fab.dart';
import '../services/creator_service.dart';

class CreatorStudioScreen extends StatefulWidget {
  const CreatorStudioScreen({super.key});
  @override
  State<CreatorStudioScreen> createState() => _CreatorStudioScreenState();
}

class _CreatorStudioScreenState extends State<CreatorStudioScreen> {
  final title = TextEditingController();
  final service = CreatorService();
  String category = 'Other';
  String msg = '';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Creator Studio')),
    floatingActionButton: const MarkeelaFab(mode: 'creator'),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _Gate(
          title: '1. Identity & Age Verification',
          subtitle: 'Creator must be verified before publishing',
        ),
        const _Gate(
          title: '2. Performer Verification & Consent',
          subtitle: 'Every depicted performer requires approved records',
        ),
        const _Gate(
          title: '3. Commercial Rights',
          subtitle: 'Distribution license must be approved',
        ),
        const _Gate(
          title: '4. Moderation',
          subtitle: 'Submission must pass moderation before publication',
        ),
        const SizedBox(height: 18),
        TextField(
          controller: title,
          decoration: const InputDecoration(labelText: 'Submission title'),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: category,
          items: [
            'Featured',
            'Trending',
            'New',
            'Other',
          ].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
          onChanged: (v) => setState(() => category = v ?? 'Other'),
          decoration: const InputDecoration(labelText: 'Category'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_file),
          label: const Text('Select / Upload Video'),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () async {
            try {
              final id = await service.submitContent(
                title: title.text.trim(),
                category: category,
              );
              setState(
                () => msg =
                    'Submitted $id. Publishing remains blocked until all gates pass.',
              );
            } catch (e) {
              setState(() => msg = '$e');
            }
          },
          icon: const Icon(Icons.send),
          label: const Text('Submit for Review'),
        ),
        if (msg.isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 12), child: Text(msg)),
      ],
    ),
  );
}

class _Gate extends StatelessWidget {
  final String title, subtitle;
  const _Gate({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.verified_user_outlined),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Chip(label: Text('REQUIRED')),
    ),
  );
}
