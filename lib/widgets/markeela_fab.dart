import 'package:flutter/material.dart';
import '../screens/markeela_screen.dart';

class MarkeelaFab extends StatelessWidget {
  final String mode;
  const MarkeelaFab({super.key, this.mode = 'assistant'});

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
    onPressed: () => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MarkeelaScreen(initialMode: mode)),
    ),
    icon: const Icon(Icons.auto_awesome),
    label: const Text('Ask Agent Duke Da Boss X'),
  );
}
