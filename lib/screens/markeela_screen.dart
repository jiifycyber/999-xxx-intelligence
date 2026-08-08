import 'package:flutter/material.dart';
import '../ai/markeela_models.dart';
import '../ai/markeela_service.dart';

class MarkeelaScreen extends StatefulWidget {
  final String initialMode;
  const MarkeelaScreen({super.key, this.initialMode = 'assistant'});

  @override
  State<MarkeelaScreen> createState() => _MarkeelaScreenState();
}

class _MarkeelaScreenState extends State<MarkeelaScreen> {
  final controller = TextEditingController();
  final service = MarkeelaService();
  final messages = <MarkeelaMessage>[];
  late String mode;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    mode = widget.initialMode;
    messages.add(
      MarkeelaMessage(
        role: 'assistant',
        content: 'Hi, I’m Markeela — your 999XXX AI assistant. How can I help?',
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> send([String? preset]) async {
    final text = (preset ?? controller.text).trim();
    if (text.isEmpty || loading) return;
    setState(() {
      messages.add(
        MarkeelaMessage(role: 'user', content: text, createdAt: DateTime.now()),
      );
      controller.clear();
      loading = true;
    });

    final response = await service.ask(message: text, mode: mode);
    if (!mounted) return;
    setState(() {
      messages.add(
        MarkeelaMessage(
          role: 'assistant',
          content: response.text,
          createdAt: DateTime.now(),
          metadata: {
            'model': response.model,
            'suggested_actions': response.suggestedActions,
          },
        ),
      );
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Row(
        children: [
          CircleAvatar(child: Icon(Icons.auto_awesome)),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Markeela', style: TextStyle(fontWeight: FontWeight.w900)),
              Text(
                '999XXX AI Agent',
                style: TextStyle(fontSize: 11, color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          initialValue: mode,
          onSelected: (v) => setState(() => mode = v),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'assistant', child: Text('Assistant')),
            PopupMenuItem(value: 'discovery', child: Text('Discovery')),
            PopupMenuItem(value: 'creator', child: Text('Creator Assistant')),
            PopupMenuItem(value: 'admin', child: Text('Admin AI')),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(child: Chip(label: Text(mode.toUpperCase()))),
          ),
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: messages.length,
            itemBuilder: (context, i) {
              final m = messages[i];
              final user = m.role == 'user';
              return Align(
                alignment: user ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 720),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: user
                        ? const Color(0xFF47206B)
                        : const Color(0xFF161620),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: user
                          ? const Color(0xFF6E2D9B)
                          : const Color(0xFF29293A),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user ? 'You' : 'Markeela',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: user
                              ? Colors.purpleAccent
                              : Colors.lightBlueAccent,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(m.content),
                      if (m.metadata?['model'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'AI: ${m.metadata!['model']}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (loading) const LinearProgressIndicator(minHeight: 2),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => send(),
                  minLines: 1,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText:
                        'Ask Agent Duke Da Boss X anything about 999XXX...',
                    prefixIcon: Icon(Icons.auto_awesome),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: loading ? null : () => send(),
                style: FilledButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(18),
                ),
                child: const Icon(Icons.arrow_upward),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
