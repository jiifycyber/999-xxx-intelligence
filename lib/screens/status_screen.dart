import 'package:flutter/material.dart';
import '../services/integration_status_service.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final items = IntegrationStatusService().all;
    return Scaffold(
      appBar: AppBar(title: const Text('System Status')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Green means the service is actually configured. 999XXX does not fake external-provider status.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          for (final x in items)
            Card(
              child: ListTile(
                leading: Icon(
                  x.ready ? Icons.check_circle : Icons.settings_outlined,
                  color: x.ready ? Colors.greenAccent : Colors.amberAccent,
                ),
                title: Text(x.name),
                subtitle: Text(x.detail),
                trailing: Text(
                  x.ready ? 'LIVE' : 'SETUP',
                  style: TextStyle(
                    color: x.ready ? Colors.greenAccent : Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
