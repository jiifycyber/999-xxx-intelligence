import 'package:flutter/material.dart';
import '../widgets/markeela_fab.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Admin Command Center')),
    floatingActionButton: const MarkeelaFab(mode: 'admin'),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _metric('Creators pending', '0', Icons.person_search),
            _metric('Rights reviews', '0', Icons.description_outlined),
            _metric('Moderation queue', '0', Icons.shield_outlined),
            _metric('Open takedowns', '0', Icons.report_outlined),
          ],
        ),
        const SizedBox(height: 16),
        for (final e in const [
          (
            'Creator verification queue',
            'Review identity/age verification status',
            Icons.badge_outlined,
          ),
          (
            'Rights & consent queue',
            'Approve performer records and commercial licenses',
            Icons.fact_check_outlined,
          ),
          (
            'Content moderation',
            'Approve/reject submissions',
            Icons.policy_outlined,
          ),
          (
            'Reports & takedowns',
            'Process rights, safety and removal requests',
            Icons.gavel_outlined,
          ),
          (
            'Catalog management',
            'Categories, features, rankings and visibility',
            Icons.video_library_outlined,
          ),
          (
            'Revenue & entitlements',
            'Purchases, subscriptions, creator payout ledger',
            Icons.payments_outlined,
          ),
          (
            'Analytics',
            'Views, retention, creators, catalog and conversion',
            Icons.analytics_outlined,
          ),
          (
            'Audit logs',
            'Review administrative actions',
            Icons.history_edu_outlined,
          ),
        ])
          Card(
            child: ListTile(
              leading: Icon(e.$3),
              title: Text(e.$1),
              subtitle: Text(e.$2),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
      ],
    ),
  );
  Widget _metric(String t, String v, IconData i) => SizedBox(
    width: 210,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(i),
            const SizedBox(height: 12),
            Text(
              v,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            Text(t),
          ],
        ),
      ),
    ),
  );
}
