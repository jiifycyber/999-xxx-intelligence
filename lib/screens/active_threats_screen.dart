import 'package:flutter/material.dart';

import '../core/genesis_theme.dart';
import '../models/security_event.dart';
import '../services/level6_event_service.dart';

class ActiveThreatsScreen extends StatefulWidget {
  const ActiveThreatsScreen({super.key});

  @override
  State<ActiveThreatsScreen> createState() => _ActiveThreatsScreenState();
}

class _ActiveThreatsScreenState extends State<ActiveThreatsScreen> {
  static bool _historicalCleanupStarted = false;

  final Set<String> _locallyResolvedIds = <String>{};

  static void _runHistoricalCleanupOnce() {
    if (_historicalCleanupStarted) return;
    _historicalCleanupStarted = true;

    Future.microtask(() async {
      try {
        final count =
            await Level6EventService.instance.resolveHistoricalYaraSelfScans();
        debugPrint(
          'YARA historical self-scan cleanup resolved $count events.',
        );
      } catch (error) {
        debugPrint('YARA historical cleanup warning: $error');
      }
    });
  }

  bool _isContained(SecurityEvent event) {
    final action = (event.action ?? '').toUpperCase();

    return action == 'BLOCKED' ||
        action == 'MITIGATED' ||
        action == 'CONTAINED' ||
        action == 'QUARANTINED' ||
        action == 'TERMINATED' ||
        action == 'ISOLATED';
  }

  bool _isTest(SecurityEvent event) {
    final rule = (event.ruleName ?? '').trim().toUpperCase();

    return rule.startsWith('TEST -') ||
        rule.contains('CIPHER_SAFE_TEST_DETECTION') ||
        rule.contains('LEVEL6_CONTROLLED_TEST');
  }

  bool _isRecent(SecurityEvent event) {
    final cutoff = DateTime.now().subtract(
      const Duration(hours: 24),
    );

    return event.occurredAt.isAfter(cutoff);
  }

  bool _isActiveThreat(SecurityEvent event) {
    if (_locallyResolvedIds.contains(event.id)) return false;

    final evidencePath =
        (event.itemPath ?? event.sanitizedPath ?? '').toLowerCase();

    final isYaraSelfScan = evidencePath.contains('endpoint_sensor/yara/') ||
        evidencePath.contains('endpoint_sensor/state/yara_production.yarc');

    if (_isTest(event) ||
        isYaraSelfScan ||
        !_isRecent(event) ||
        _isContained(event) ||
        (event.action ?? "").toUpperCase() == "RESOLVED") {
      return false;
    }

    final rule = (event.ruleName ?? '').toLowerCase();

    final category = event.category.toUpperCase();

    final correlated = rule.contains(
      'high confidence correlated endpoint threat',
    );

    final intel = rule.contains('threat intelligence match');

    // A real YARA detection with structured file evidence is an active
    // endpoint threat even when it is not a network/intelligence event.
    final yaraDetection = rule.contains('yara') && event.hasFileEvidence;

    final suspiciousOutbound =
        category == 'SUSPICIOUS_OUTBOUND_CONNECTION' && event.confidence >= 90;

    final confirmed = event.confirmed || category == 'CONFIRMED_INCIDENT';

    final critical =
        event.severity.toUpperCase() == 'CRITICAL' && event.confidence >= 90;

    return correlated ||
        intel ||
        yaraDetection ||
        suspiciousOutbound ||
        confirmed ||
        critical;
  }

  Color _severityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
        return GenesisColors.danger;
      case 'HIGH':
        return const Color(0xFFFF8A26);
      case 'MEDIUM':
        return GenesisColors.warning;
      default:
        return GenesisColors.cyan;
    }
  }

  IconData _eventIcon(SecurityEvent event) {
    final rule = (event.ruleName ?? '').toLowerCase();

    if (rule.contains('yara') || rule.contains('file')) {
      return Icons.description_outlined;
    }

    if (rule.contains('outbound') || rule.contains('threat intelligence')) {
      return Icons.public_rounded;
    }

    if (rule.contains('persistence')) {
      return Icons.settings_suggest_outlined;
    }

    if (rule.contains('process')) {
      return Icons.monitor_heart_outlined;
    }

    return Icons.warning_amber_rounded;
  }

  String _age(DateTime time) {
    final difference = DateTime.now().difference(time);

    if (difference.inMinutes < 1) {
      return 'now';
    }

    if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    }

    return '${difference.inHours} hr ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GenesisColors.voidBlack,
      body: SafeArea(
        child: StreamBuilder<List<SecurityEvent>>(
          stream: Level6EventService.instance.watchEvents(),
          builder: (context, snapshot) {
            _runHistoricalCleanupOnce();
            final all = snapshot.data ?? const <SecurityEvent>[];

            final events = all.where(_isActiveThreat).toList()
              ..sort(
                (a, b) => b.occurredAt.compareTo(a.occurredAt),
              );

            final critical = events
                .where(
                  (event) => event.severity.toUpperCase() == 'CRITICAL',
                )
                .length;

            final highest = events.isEmpty
                ? 0
                : events
                    .map(
                      (event) => event.threatScore,
                    )
                    .reduce(
                      (a, b) => a > b ? a : b,
                    );

            return Column(
              children: [
                _Header(
                  count: events.length,
                  critical: critical,
                  highest: highest,
                ),
                Expanded(
                  child: events.isEmpty
                      ? const _EmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            12,
                            12,
                            12,
                            110,
                          ),
                          itemCount: events.length,
                          separatorBuilder: (_, __) => const SizedBox(
                            height: 9,
                          ),
                          itemBuilder: (context, index) {
                            final event = events[index];

                            return _ThreatCard(
                              event: event,
                              severityColor: _severityColor(
                                event.severity,
                              ),
                              icon: _eventIcon(event),
                              age: _age(
                                event.occurredAt,
                              ),
                              onInvestigate: () async {
                                final resolvedId =
                                    await showModalBottomSheet<String>(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => _ThreatDetails(
                                    event: event,
                                  ),
                                );

                                if (resolvedId != null && mounted) {
                                  setState(() {
                                    _locallyResolvedIds.add(resolvedId);
                                  });
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.count,
    required this.critical,
    required this.highest,
  });

  final int count;
  final int critical;
  final int highest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        12,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF061329),
        border: Border(
          bottom: BorderSide(
            color: GenesisColors.cyan,
            width: .5,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: GenesisColors.danger,
                size: 30,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE THREATS',
                      style: TextStyle(
                        color: GenesisColors.text,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'UNRESOLVED SECURITY EVENTS REQUIRING ATTENTION',
                      style: TextStyle(
                        color: GenesisColors.muted,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _HeaderMetric(
                  value: '$highest',
                  label: 'TOP RISK',
                  color: GenesisColors.cyan,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _HeaderMetric(
                  value: '$count',
                  label: 'ACTIVE',
                  color: GenesisColors.danger,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _HeaderMetric(
                  value: '$critical',
                  label: 'CRITICAL',
                  color: GenesisColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: GenesisColors.panelRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: .8),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: GenesisColors.muted,
              fontSize: 7,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreatCard extends StatelessWidget {
  const _ThreatCard({
    required this.event,
    required this.severityColor,
    required this.icon,
    required this.age,
    required this.onInvestigate,
  });

  final SecurityEvent event;
  final Color severityColor;
  final IconData icon;
  final String age;
  final VoidCallback onInvestigate;

  @override
  Widget build(BuildContext context) {
    final title = event.ruleName?.trim().isNotEmpty == true
        ? event.ruleName!
        : event.category.replaceAll('_', ' ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GenesisColors.panelRaised,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: GenesisColors.cyan.withValues(
            alpha: .28,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: severityColor.withValues(
                alpha: .10,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: severityColor,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: GenesisColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${event.provider} • $age',
                  style: const TextStyle(
                    color: GenesisColors.muted,
                    fontSize: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 5,
                  children: [
                    _Pill(
                      text: event.severity,
                      color: severityColor,
                    ),
                    _Pill(
                      text: 'SCORE ${event.threatScore}',
                      color: GenesisColors.warning,
                    ),
                    _Pill(
                      text: '${event.confidence.toStringAsFixed(0)}%',
                      color: GenesisColors.cyan,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onInvestigate,
            style: OutlinedButton.styleFrom(
              foregroundColor: GenesisColors.cyan,
              side: const BorderSide(
                color: GenesisColors.cyan,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
              ),
            ),
            child: const Text(
              'INVESTIGATE',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreatDetails extends StatelessWidget {
  const _ThreatDetails({
    required this.event,
  });

  final SecurityEvent event;

  Widget row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: const TextStyle(
                color: GenesisColors.muted,
                fontSize: 9,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: GenesisColors.text,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = event.ruleName?.trim().isNotEmpty == true
        ? event.ruleName!
        : event.category.replaceAll('_', ' ');

    final filePath = (event.itemPath ?? event.sanitizedPath ?? '').trim();
    final canQuarantine = event.hasFileEvidence &&
        filePath.isNotEmpty &&
        (event.endpointId ?? '').trim().isNotEmpty;

    return FractionallySizedBox(
      heightFactor: .88,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF061329),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(22),
          ),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              28,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: GenesisColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(
                      context,
                    ),
                    icon: const Icon(
                      Icons.close,
                      color: GenesisColors.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: GenesisColors.panelRaised,
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                  border: Border.all(
                    color: GenesisColors.cyan.withValues(
                      alpha: .25,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    row(
                      'Severity',
                      event.severity,
                    ),
                    row(
                      'Threat Score',
                      '${event.threatScore}',
                    ),
                    row(
                      'Confidence',
                      '${event.confidence.toStringAsFixed(0)}%',
                    ),
                    row(
                      'Category',
                      event.category,
                    ),
                    row(
                      'Provider',
                      event.provider,
                    ),
                    row(
                      'Rule',
                      event.ruleName ?? '—',
                    ),
                    row(
                      'Action',
                      event.action ?? 'OBSERVED',
                    ),
                    row(
                      'Confirmed',
                      event.confirmed ? 'YES' : 'NO',
                    ),
                    row(
                      'Occurred',
                      event.occurredAt.toLocal().toString(),
                    ),
                    row(
                      'Target Asset',
                      event.targetAssetId ?? '—',
                    ),
                    row(
                      'Endpoint',
                      event.endpointId ?? '—',
                    ),
                    row(
                      'File Evidence',
                      filePath.isEmpty ? '—' : filePath,
                    ),
                    row(
                      'Source',
                      event.sourceIpPrefix ?? event.sourceCountry ?? '—',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'RESPONSE ACTIONS',
                style: TextStyle(
                  color: GenesisColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: canQuarantine
                      ? () async {
                          final approved = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) {
                                  return AlertDialog(
                                    title: const Text('Quarantine File?'),
                                    content: Text(
                                      'Level 6 will request quarantine of:\n\n'
                                      '$filePath\n\n'
                                      'The endpoint will verify the file, '
                                      'calculate SHA-256, and move it into '
                                      'the quarantine vault.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(dialogContext, false);
                                        },
                                        child: const Text('CANCEL'),
                                      ),
                                      FilledButton(
                                        onPressed: () {
                                          Navigator.pop(dialogContext, true);
                                        },
                                        child: const Text('QUARANTINE'),
                                      ),
                                    ],
                                  );
                                },
                              ) ??
                              false;

                          if (!approved || !context.mounted) {
                            return;
                          }

                          try {
                            await Level6EventService.instance
                                .requestQuarantineFile(event);

                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Quarantine command queued for endpoint.',
                                ),
                              ),
                            );
                          } catch (error) {
                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Quarantine request failed: $error',
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('QUARANTINE FILE'),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search,
                      ),
                      label: const Text(
                        'INVESTIGATE',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(
                        Icons.block,
                      ),
                      label: const Text(
                        'BLOCK IP',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(
                        Icons.stop_circle_outlined,
                      ),
                      label: const Text(
                        'TERMINATE',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          await Level6EventService.instance
                              .resolveEvent(event.id);

                          if (!context.mounted) return;

                          Navigator.pop(context, event.id);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Threat marked as resolved. Evidence retained."),
                            ),
                          );
                        } catch (error) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Resolve failed: $error"),
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.check_circle_outline,
                      ),
                      label: const Text(
                        'RESOLVE',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Containment controls are disabled until the response engine is verified.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: GenesisColors.muted,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: color.withValues(alpha: .7),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 7,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: GenesisColors.emerald,
            size: 48,
          ),
          SizedBox(height: 12),
          Text(
            'NO ACTIVE THREATS',
            style: TextStyle(
              color: GenesisColors.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'No unresolved high-confidence detections.',
            style: TextStyle(
              color: GenesisColors.muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
