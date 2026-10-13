import 'agent_x_screen.dart';
import 'child_protection_screen.dart';
import '../widgets/ic391_module_workspace.dart';
import 'active_cases_screen.dart';
import 'missing_children_screen.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/genesis_theme.dart';
import '../models/security_event.dart';
import '../services/level6_event_service.dart';
import '../services/cipher_backend_service.dart';
import '../widgets/detailed_world_map.dart';
import '../widgets/premium_intelligence_visuals.dart';
import '../widgets/live_endpoint_fleet.dart';
import '../widgets/live_camera_feed.dart';
import '../widgets/camera_vault_panel.dart';
import 'active_threats_screen.dart';

class WarRoomScreen extends StatefulWidget {
  const WarRoomScreen({super.key});

  @override
  State<WarRoomScreen> createState() => _WarRoomScreenState();
}

class _WarRoomScreenState extends State<WarRoomScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, viewport) {
        if (viewport.maxWidth < 700) {
          return _MobileWarRoom(
            selected: _selected,
            pulse: _pulse,
            onSelected: (value) => setState(() => _selected = value),
          );
        }

        final canvasWidth = math.max(1480.0, viewport.maxWidth);
        final canvasHeight = math.max(832.0, viewport.maxHeight);

        return Scaffold(
          backgroundColor: GenesisColors.voidBlack,
          body: SizedBox.expand(
            child: ColoredBox(
              color: GenesisColors.voidBlack,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: SizedBox(
                  width: canvasWidth,
                  height: canvasHeight,
                  child: Column(
                    children: [
                      const _CommandHeader(),
                      Expanded(
                        child: Row(
                          children: [
                            _NavigationRail(
                              selected: _selected,
                              onSelected: (value) =>
                                  setState(() => _selected = value),
                            ),
                            Expanded(
                              child: _selected == 0
                                  ? _CommandCenter(
                                      pulse: _pulse,
                                      onSelected: (value) =>
                                          setState(() => _selected = value),
                                    )
                                  : _SectionScreen(
                                      index: _selected,
                                      pulse: _pulse,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const _OperationConsole(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MobileWarRoom extends StatelessWidget {
  const _MobileWarRoom({
    required this.selected,
    required this.pulse,
    required this.onSelected,
  });

  final int selected;
  final Animation<double> pulse;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GenesisColors.voidBlack,
      body: SafeArea(
        child: Column(
          children: [
            _MobileHeader(
              selected: selected,
              onSelected: onSelected,
            ),
            Expanded(
              child: selected == 0
                  ? _MobileCommandCenter(
                      pulse: pulse,
                      onSelected: onSelected,
                    )
                  : _MobileDestination(
                      selected: selected,
                      pulse: pulse,
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _MobileBottomNavigation(
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader({
    required this.selected,
    required this.onSelected,
  });

  final int selected;
  final ValueChanged<int> onSelected;

  void _showMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF050B1A),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .72,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _NavigationRail._items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 5),
              itemBuilder: (context, index) {
                final item = _NavigationRail._items[index];
                final active = selected == index;

                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: active ? GenesisColors.gold : GenesisColors.border,
                    ),
                  ),
                  tileColor: GenesisColors.panelRaised,
                  leading: Icon(
                    item.$2,
                    color: active ? GenesisColors.gold : GenesisColors.cyan,
                  ),
                  title: Text(
                    item.$1,
                    style: TextStyle(
                      color: active ? GenesisColors.gold : GenesisColors.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onTap: () {
                    onSelected(index);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF050B1A),
        border: Border(
          bottom: BorderSide(color: GenesisColors.border),
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/xxxdefense_icon.png',
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UNITED NATIONS OF IC-391',
                  style: TextStyle(
                    color: GenesisColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'GLOBAL SECURITY INTELLIGENCE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: GenesisColors.muted,
                    fontSize: 7,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.verified_user_rounded,
            color: GenesisColors.emerald,
            size: 22,
          ),
          const SizedBox(width: 4),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ALL SECURE',
                style: TextStyle(
                  color: GenesisColors.emerald,
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'AUTHORIZED',
                style: TextStyle(
                  color: GenesisColors.warning,
                  fontSize: 6,
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: 'Open command menu',
            onPressed: () => _showMenu(context),
            icon: const Icon(
              Icons.menu_rounded,
              color: GenesisColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileCommandHero extends StatelessWidget {
  const _MobileCommandHero();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');

    return Container(
      height: 88,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: GenesisColors.cyan.withValues(alpha: .32),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF061835),
            Color(0xFF082653),
            Color(0xFF07172F),
            Color(0xFF13082D),
          ],
          stops: [0, .34, .72, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: GenesisColors.cyan.withValues(alpha: .12),
            blurRadius: 24,
          ),
          BoxShadow(
            color: GenesisColors.purple.withValues(alpha: .10),
            blurRadius: 30,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          children: [
            Positioned(
              left: -70,
              right: -70,
              top: -118,
              height: 210,
              child: IgnorePointer(
                child: Opacity(
                  opacity: .60,
                  child: CustomPaint(
                    painter: _CommandGlobePainter(),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      GenesisColors.cyan.withValues(alpha: .75),
                      GenesisColors.purple.withValues(alpha: .70),
                      GenesisColors.pink.withValues(alpha: .50),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GLOBAL EYES.',
                          style: TextStyle(
                            color: GenesisColors.cyan,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.7,
                          ),
                        ),
                        Text(
                          'FASTER INTELLIGENCE.',
                          style: TextStyle(
                            color: GenesisColors.text,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.35,
                          ),
                        ),
                        Text(
                          'SAFER TOMORROW.',
                          style: TextStyle(
                            color: GenesisColors.muted,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'LEVEL 6 COMMAND',
                        style: TextStyle(
                          color: GenesisColors.muted,
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$hh:$mm:$ss',
                        style: const TextStyle(
                          color: GenesisColors.cyan,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const _MiniPill(
                        'LIVE TELEMETRY',
                        GenesisColors.emerald,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommandGlobePainter extends CustomPainter {
  const _CommandGlobePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .92);
    final radius = size.width * .42;

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = GenesisColors.cyan.withValues(alpha: .055)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        20,
      );

    canvas.drawCircle(center, radius, glow);

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = GenesisColors.cyan.withValues(alpha: .32);

    canvas.drawCircle(center, radius, outline);

    final latitude = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .65
      ..color = GenesisColors.cyan.withValues(alpha: .19);

    for (final scale in [.24, .48, .72]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2,
          height: radius * 2 * scale,
        ),
        latitude,
      );
    }

    for (final scale in [.34, .62]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2 * scale,
          height: radius * 2,
        ),
        latitude,
      );
    }

    final node = Paint()..color = GenesisColors.cyan.withValues(alpha: .75);

    for (final point in [
      Offset(center.dx - radius * .62, center.dy - radius * .16),
      Offset(center.dx - radius * .22, center.dy - radius * .48),
      Offset(center.dx + radius * .16, center.dy - radius * .34),
      Offset(center.dx + radius * .58, center.dy - radius * .10),
    ]) {
      canvas.drawCircle(point, 2.2, node);
    }
  }

  @override
  bool shouldRepaint(covariant _CommandGlobePainter oldDelegate) => false;
}

class _MobileKpiStrip extends StatelessWidget {
  const _MobileKpiStrip();

  static bool _isContained(SecurityEvent event) {
    final action = (event.action ?? '').toUpperCase();

    return action == 'BLOCKED' ||
        action == 'MITIGATED' ||
        action == 'CONTAINED' ||
        action == 'QUARANTINED' ||
        action == 'TERMINATED' ||
        action == 'ISOLATED';
  }

  static bool _isTest(SecurityEvent event) {
    final rule = (event.ruleName ?? '').trim().toUpperCase();

    return rule.startsWith('TEST -') ||
        rule.contains('CIPHER_SAFE_TEST_DETECTION') ||
        rule.contains('LEVEL6_CONTROLLED_TEST');
  }

  static bool _isRecent(SecurityEvent event) {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return event.occurredAt.isAfter(cutoff);
  }

  static bool _isActiveThreat(SecurityEvent event) {
    final evidencePath =
        (event.itemPath ?? event.sanitizedPath ?? '').toLowerCase();

    final isYaraSelfScan = evidencePath.contains('endpoint_sensor/yara/') ||
        evidencePath.contains('endpoint_sensor/state/yara_production.yarc');

    if (_isTest(event) ||
        isYaraSelfScan ||
        !_isRecent(event) ||
        _isContained(event) ||
        (event.action ?? '').toUpperCase() == 'RESOLVED') {
      return false;
    }

    final rule = (event.ruleName ?? '').toLowerCase();
    final category = event.category.toUpperCase();

    final correlatedThreat =
        rule.contains('high confidence correlated endpoint threat');

    final threatIntelMatch = rule.contains('threat intelligence match');

    final yaraDetection = rule.contains('yara') && event.hasFileEvidence;

    final suspiciousOutbound =
        category == 'SUSPICIOUS_OUTBOUND_CONNECTION' && event.confidence >= 90;

    final confirmedIncident =
        event.confirmed || category == 'CONFIRMED_INCIDENT';

    final criticalThreat =
        event.severity.toUpperCase() == 'CRITICAL' && event.confidence >= 90;

    return correlatedThreat ||
        threatIntelMatch ||
        yaraDetection ||
        suspiciousOutbound ||
        confirmedIncident ||
        criticalThreat;
  }

  static int _globalRisk(List<SecurityEvent> events) {
    var highest = 0;

    for (final event in events) {
      if (!_isActiveThreat(event)) {
        continue;
      }

      var candidate = event.threatScore;
      final rule = (event.ruleName ?? '').toLowerCase();

      if (rule.contains('high confidence correlated endpoint threat')) {
        candidate = event.confidence.round();
      }

      if (candidate > highest) {
        highest = candidate;
      }
    }

    return highest.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SecurityEvent>>(
      stream: Level6EventService.instance.watchEvents(),
      builder: (context, snapshot) {
        final events = snapshot.data ?? const <SecurityEvent>[];

        final active = events.where(_isActiveThreat).length;

        final critical = events.where((event) {
          return _isActiveThreat(event) &&
              event.severity.toUpperCase() == 'CRITICAL';
        }).length;

        final contained = events.where(_isContained).length;
        final risk = _globalRisk(events);

        final data = [
          (
            risk.toString(),
            'GLOBAL RISK',
            Icons.public_rounded,
            GenesisColors.cyan,
            0
          ),
          (
            active.toString(),
            'ACTIVE THREATS',
            Icons.warning_amber_rounded,
            GenesisColors.danger,
            1
          ),
          (
            critical.toString(),
            'CRITICAL',
            Icons.gps_fixed_rounded,
            GenesisColors.purpleBright,
            2
          ),
          (
            contained.toString(),
            'CONTAINED',
            Icons.bar_chart_rounded,
            GenesisColors.emerald,
            3
          ),
        ];

        return Row(
          children: [
            for (var index = 0; index < data.length; index++) ...[
              Expanded(
                child: _PremiumKpiCard(
                  value: data[index].$1,
                  label: data[index].$2,
                  icon: data[index].$3,
                  color: data[index].$4,
                  variant: data[index].$5,
                ),
              ),
              if (index != data.length - 1) const SizedBox(width: 7),
            ],
          ],
        );
      },
    );
  }
}

class _PremiumKpiCard extends StatelessWidget {
  const _PremiumKpiCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.variant,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final int variant;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: color.withValues(alpha: .90),
          width: 1.15,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: .095),
            const Color(0xFF092149),
            const Color(0xFF07152D),
          ],
          stops: const [0, .35, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .17),
            blurRadius: 17,
          ),
          const BoxShadow(
            color: Color(0x33000000),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 33,
              child: Opacity(
                opacity: .90,
                child: CustomPaint(
                  painter: _KpiSparkPainter(
                    color: color,
                    variant: variant,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 7,
              top: 6,
              right: 7,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      color.withValues(alpha: .90),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 12, 5, 7),
              child: Column(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: .09),
                      border: Border.all(
                        color: color.withValues(alpha: .24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: .15),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 27,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.8,
                      shadows: [
                        Shadow(
                          color: color.withValues(alpha: .35),
                          blurRadius: 9,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: GenesisColors.text,
                      fontSize: 6.1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .20,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_downward_rounded,
                        color: GenesisColors.emerald,
                        size: 8,
                      ),
                      const SizedBox(width: 2),
                      const Flexible(
                        child: Text(
                          'LIVE 24H',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: GenesisColors.muted,
                            fontSize: 5.3,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiSparkPainter extends CustomPainter {
  const _KpiSparkPainter({
    required this.color,
    required this.variant,
  });

  final Color color;
  final int variant;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = color.withValues(alpha: .06)
      ..strokeWidth = .5;

    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        grid,
      );
    }

    final presets = <List<double>>[
      [.78, .68, .72, .49, .58, .40, .46, .28, .37, .18],
      [.68, .73, .59, .63, .47, .55, .34, .42, .23, .12],
      [.74, .62, .69, .51, .55, .39, .43, .33, .24, .15],
      [.81, .70, .76, .61, .65, .48, .52, .37, .43, .22],
    ];

    final values = presets[variant % presets.length];

    final path = Path();

    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height * values[i];

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: .18),
            color.withValues(alpha: 0),
          ],
        ).createShader(
          Offset.zero & size,
        ),
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color.withValues(alpha: .85),
    );
  }

  @override
  bool shouldRepaint(covariant _KpiSparkPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.variant != variant;
  }
}

class _MobileCommandCenter extends StatelessWidget {
  const _MobileCommandCenter({
    required this.pulse,
    required this.onSelected,
  });

  final Animation<double> pulse;
  final ValueChanged<int> onSelected;

  Widget _pair({
    required Widget left,
    required Widget right,
    required double height,
  }) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          const SizedBox(width: 7),
          Expanded(child: right),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment.topCenter,
          radius: 1.22,
          colors: [
            Color(0xFF0B2F6A),
            Color(0xFF071B3C),
            Color(0xFF080C22),
            Color(0xFF180A35),
            GenesisColors.voidBlack,
          ],
          stops: [0, .28, .52, .78, 1],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(7, 7, 7, 14),
        children: [
          const _MobileCommandHero(),
          const SizedBox(
            height: 148,
            child: _MobileKpiStrip(),
          ),
          const SizedBox(height: 7),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ActiveThreatsScreen(),
                ),
              );
            },
            child: SizedBox(
              height: 390,
              child: _MobileThreatMatrix(pulse: pulse),
            ),
          ),
          const SizedBox(height: 7),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelected(4),
            child: const SizedBox(
              height: 235,
              child: _IntelligenceStream(),
            ),
          ),
          const SizedBox(height: 7),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelected(15),
            child: const SizedBox(
              height: 260,
              child: _AgentDukePanel(),
            ),
          ),
          const SizedBox(height: 7),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelected(11),
            child: const SizedBox(
              height: 245,
              child: _PrincePanel(),
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            height: 270,
            child: _BiometricPanel(
              onTap: () => onSelected(6),
            ),
          ),
          const SizedBox(height: 7),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelected(5),
            child: const SizedBox(
              height: 275,
              child: LiveEndpointFleet(),
            ),
          ),
          const SizedBox(height: 7),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelected(6),
            child: const SizedBox(
              height: 300,
              child: _CameraPanel(),
            ),
          ),
          const SizedBox(height: 7),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => Scaffold(
                    backgroundColor: GenesisColors.voidBlack,
                    appBar: AppBar(
                      title: const Text('NETWORK TRAFFIC ANALYTICS'),
                      backgroundColor: GenesisColors.voidBlack,
                    ),
                    body: const SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: _TrafficPanel(),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: const SizedBox(
              height: 195,
              child: _TrafficPanel(),
            ),
          ),
          const SizedBox(height: 7),
          _pair(
            left: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(11),
              child: const _RecoveryPanel(),
            ),
            right: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(9),
              child: const _EvidencePanel(),
            ),
            height: 218,
          ),
        ],
      ),
    );
  }
}

class _MobileDestination extends StatelessWidget {
  const _MobileDestination({
    required this.selected,
    required this.pulse,
  });

  final int selected;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    if (selected == 2) return const ActiveCasesScreen();
    if (selected == 3) return const ChildProtectionScreen();
    if (selected == 15) return AgentXScreen();

    final safeIndex = selected.clamp(
      0,
      _SectionScreen.sections.length - 1,
    );
    final section = _SectionScreen.sections[safeIndex];

    Widget content;

    if (safeIndex == 1) {
      content = const SizedBox(
        height: 850,
        child: MissingChildrenScreen(),
      );
    } else if (safeIndex == 6) {
      content = const SizedBox(
        height: 980,
        child: CameraVaultPanel(),
      );
    } else if (safeIndex == 9) {
      content = const SizedBox(
        height: 400,
        child: _EvidencePanel(),
      );
    } else {
      content = SizedBox(
        height: 850,
        child: IC391ModuleWorkspace(
          key: ValueKey('ic391_mobile_module_$safeIndex'),
          title: section.$1,
          subtitle: section.$2,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        content,
      ],
    );
  }
}

class _MobileBottomNavigation extends StatelessWidget {
  const _MobileBottomNavigation({
    required this.selected,
    required this.onSelected,
  });

  final int selected;
  final ValueChanged<int> onSelected;

  static const destinations = [
    ('COMMAND', Icons.home_rounded, 0),
    ('MISSING', Icons.child_care_rounded, 1),
    ('CASES', Icons.folder_open_rounded, 2),
    ('CAMERAS', Icons.videocam_rounded, 6),
    ('ADMIN', Icons.settings_rounded, 14),
    ('AGENT X', Icons.smart_toy_rounded, 15),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: Color(0xFF050B1A),
          border: Border(
            top: BorderSide(color: GenesisColors.border),
          ),
        ),
        child: Row(
          children: [
            for (final item in destinations)
              Expanded(
                child: InkWell(
                  onTap: () => onSelected(item.$3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.$2,
                        size: 21,
                        color: selected == item.$3
                            ? GenesisColors.gold
                            : GenesisColors.muted,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.$1,
                        maxLines: 1,
                        style: TextStyle(
                          color: selected == item.$3
                              ? GenesisColors.gold
                              : GenesisColors.muted,
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CommandHeader extends StatelessWidget {
  const _CommandHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF050B1A),
        border: Border(bottom: BorderSide(color: GenesisColors.border)),
      ),
      child: Row(
        children: [
          const Text('391',
              style: TextStyle(
                  color: GenesisColors.gold,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1)),
          const SizedBox(width: 12),
          Container(width: 1, height: 42, color: GenesisColors.goldSoft),
          const SizedBox(width: 12),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('UNITED NATIONS OF IC-391',
                  style: TextStyle(
                      color: GenesisColors.text,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1)),
              Text('LEVEL 6 — CYBER OPERATIONS COMMAND',
                  style: TextStyle(
                      color: GenesisColors.muted,
                      fontSize: 8,
                      letterSpacing: 1.6)),
            ],
          ),
          const Spacer(),
          const Text(
            'MISSING CHILDREN • CHILD PROTECTION • INVESTIGATION & RECOVERY',
            style: TextStyle(
                color: GenesisColors.warning,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 1),
          ),
          const Spacer(),
          const _ReadinessHeader(),
          const SizedBox(width: 22),
          const _HeaderStatus(),
          const SizedBox(width: 22),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('THU, SEP 17, 2026',
                  style: TextStyle(color: GenesisColors.muted, fontSize: 8)),
              Text('05:23:35 UTC',
                  style: TextStyle(
                      color: GenesisColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              Text('CHILD PROTECTION',
                  style: TextStyle(color: GenesisColors.cyan, fontSize: 7)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadinessHeader extends StatelessWidget {
  const _ReadinessHeader();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Text('CHILD PROTECTION INTELLIGENCE',
                  style: TextStyle(color: GenesisColors.muted, fontSize: 8)),
              Spacer(),
              Text('97%',
                  style: TextStyle(
                      color: GenesisColors.emerald,
                      fontWeight: FontWeight.w900)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const LinearProgressIndicator(
                value: .97,
                minHeight: 6,
                backgroundColor: GenesisColors.panelRaised,
                color: GenesisColors.emerald,
              ),
            ),
          ],
        ),
      );
}

class _HeaderStatus extends StatelessWidget {
  const _HeaderStatus();

  @override
  Widget build(BuildContext context) =>
      const Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Icon(Icons.verified_user_rounded,
            color: GenesisColors.emerald, size: 28),
        SizedBox(width: 8),
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('IC-391 SYSTEM ACTIVE',
                  style: TextStyle(
                      color: GenesisColors.emerald,
                      fontSize: 11,
                      fontWeight: FontWeight.w900)),
              Text('CHILD PROTECTION ACTIVE',
                  style: TextStyle(color: GenesisColors.emerald, fontSize: 7)),
            ]),
      ]);
}

class _NavigationRail extends StatelessWidget {
  const _NavigationRail({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  static const _items = [
    ('COMMAND CENTER', Icons.home_rounded),
    ('MISSING CHILDREN', Icons.child_care_rounded),
    ('ACTIVE CASES', Icons.folder_open_rounded),
    ('CHILD PROTECTION', Icons.shield_rounded),
    ('OSINT INVESTIGATIONS', Icons.search_rounded),
    ('MAPS & LOCATION ANALYSIS', Icons.map_rounded),
    ('CAMERAS & SURVEILLANCE', Icons.videocam_rounded),
    ('IMAGE & VIDEO ANALYSIS', Icons.image_search_rounded),
    ('DIGITAL FORENSICS', Icons.fingerprint_rounded),
    ('EVIDENCE VAULT', Icons.lock_rounded),
    ('ALERTS & BULLETINS', Icons.warning_rounded),
    ('RECOVERY OPERATIONS', Icons.handshake_rounded),
    ('PARTNER / AGENCY SOURCES', Icons.groups_rounded),
    ('REPORTS', Icons.description_rounded),
    ('SYSTEM ADMIN', Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.fromLTRB(7, 8, 7, 7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF07152C),
            Color(0xFF050B1A),
            Color(0xFF13092F),
          ],
        ),
        border: const Border(
          right: BorderSide(color: GenesisColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: GenesisColors.cyan.withValues(alpha: .08),
            blurRadius: 18,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(11),
                onTap: () => onSelected(15),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: GenesisColors.gold),
                    color: GenesisColors.gold.withValues(alpha: .12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.smart_toy_rounded,
                        color: GenesisColors.gold,
                        size: 22,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'AGENT X',
                          style: TextStyle(
                            color: GenesisColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final active = selected == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(11),
                      onTap: () => onSelected(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        height: 47,
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: active
                                ? [
                                    GenesisColors.gold.withValues(alpha: .24),
                                    GenesisColors.purple.withValues(alpha: .18),
                                    GenesisColors.panelRaised,
                                  ]
                                : [
                                    GenesisColors.panelRaised
                                        .withValues(alpha: .92),
                                    GenesisColors.glassPurple
                                        .withValues(alpha: .82),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: active
                                ? GenesisColors.gold
                                : GenesisColors.purpleBright
                                    .withValues(alpha: .46),
                            width: active ? 1.35 : .75,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (active
                                      ? GenesisColors.gold
                                      : GenesisColors.purple)
                                  .withValues(alpha: active ? .24 : .10),
                              blurRadius: active ? 10 : 6,
                              spreadRadius: active ? .4 : 0,
                            ),
                            BoxShadow(
                              color: GenesisColors.cyan.withValues(alpha: .05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: 31,
                              height: 31,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: active
                                      ? [
                                          GenesisColors.gold
                                              .withValues(alpha: .30),
                                          GenesisColors.purple
                                              .withValues(alpha: .22),
                                        ]
                                      : [
                                          GenesisColors.cyan
                                              .withValues(alpha: .12),
                                          GenesisColors.purple
                                              .withValues(alpha: .12),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: active
                                      ? GenesisColors.gold
                                      : GenesisColors.cyan
                                          .withValues(alpha: .38),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (active
                                            ? GenesisColors.gold
                                            : GenesisColors.cyan)
                                        .withValues(alpha: .18),
                                    blurRadius: 7,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _items[index].$2,
                                color: active
                                    ? GenesisColors.gold
                                    : GenesisColors.cyan,
                                size: 17,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _items[index].$1,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: active
                                      ? GenesisColors.text
                                      : const Color(0xFFC6D8E7),
                                  fontSize: 8.2,
                                  height: 1.08,
                                  letterSpacing: .25,
                                  fontWeight: active
                                      ? FontWeight.w900
                                      : FontWeight.w700,
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: 3,
                              height: active ? 25 : 12,
                              decoration: BoxDecoration(
                                color: active
                                    ? GenesisColors.gold
                                    : GenesisColors.cyan.withValues(alpha: .35),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: active
                                    ? [
                                        BoxShadow(
                                          color: GenesisColors.gold
                                              .withValues(alpha: .60),
                                          blurRadius: 7,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  GenesisColors.panelRaised.withValues(alpha: .95),
                  GenesisColors.glassPurple.withValues(alpha: .88),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: GenesisColors.purpleBright.withValues(alpha: .52),
              ),
              boxShadow: [
                BoxShadow(
                  color: GenesisColors.purple.withValues(alpha: .16),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '391',
                      style: TextStyle(
                        color: GenesisColors.gold,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.shield_rounded,
                      color: GenesisColors.emerald,
                      size: 17,
                    ),
                  ],
                ),
                Text(
                  'UNITED NATIONS OF IC-391',
                  style: TextStyle(
                    color: GenesisColors.text,
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'PEOPLE  •  TECHNOLOGY\nRESILIENCE  •  A SAFER TOMORROW',
                  style: TextStyle(
                    color: GenesisColors.muted,
                    fontSize: 5.7,
                    height: 1.45,
                    letterSpacing: .35,
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

class _CommandCenter extends StatelessWidget {
  const _CommandCenter({
    required this.pulse,
    required this.onSelected,
  });

  final Animation<double> pulse;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.2,
          colors: [
            Color(0xFF071D42),
            GenesisColors.voidBlack,
            Color(0xFF13092F),
          ],
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(children: [
        const SizedBox(height: 76, child: _KpiStrip()),
        const SizedBox(height: 8),
        Expanded(
          flex: 52,
          child: Row(children: [
            Expanded(child: _ThreatMatrix(pulse: pulse)),
            const SizedBox(width: 8),
            const SizedBox(width: 315, child: _IntelligenceStream()),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          flex: 25,
          child: Row(children: [
            const Expanded(flex: 3, child: _AgentDukePanel()),
            const SizedBox(width: 8),
            const Expanded(flex: 3, child: _PrincePanel()),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _BiometricPanel(
                onTap: () => onSelected(6),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(flex: 3, child: LiveEndpointFleet()),
          ]),
        ),
        const SizedBox(height: 8),
        const Expanded(
          flex: 18,
          child: Row(children: [
            Expanded(flex: 4, child: _TrafficPanel()),
            SizedBox(width: 8),
            Expanded(flex: 3, child: _CameraPanel()),
            SizedBox(width: 8),
            Expanded(flex: 3, child: _RecoveryPanel()),
            SizedBox(width: 8),
            Expanded(flex: 3, child: _EvidencePanel()),
          ]),
        ),
      ]),
    );
  }
}

class _KpiStrip extends StatelessWidget {
  const _KpiStrip();

  static bool _isContained(SecurityEvent event) {
    final action = (event.action ?? '').toUpperCase();

    return action == 'BLOCKED' ||
        action == 'MITIGATED' ||
        action == 'CONTAINED' ||
        action == 'QUARANTINED' ||
        action == 'TERMINATED' ||
        action == 'ISOLATED';
  }

  static bool _isTest(SecurityEvent event) {
    final rule = (event.ruleName ?? '').trim().toUpperCase();

    return rule.startsWith('TEST -') ||
        rule.contains('CIPHER_SAFE_TEST_DETECTION') ||
        rule.contains('LEVEL6_CONTROLLED_TEST');
  }

  static bool _isRecent(SecurityEvent event) {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return event.occurredAt.isAfter(cutoff);
  }

  static bool _isActiveThreat(SecurityEvent event) {
    final evidencePath =
        (event.itemPath ?? event.sanitizedPath ?? '').toLowerCase();

    final isYaraSelfScan = evidencePath.contains('endpoint_sensor/yara/') ||
        evidencePath.contains('endpoint_sensor/state/yara_production.yarc');

    if (_isTest(event) ||
        isYaraSelfScan ||
        !_isRecent(event) ||
        _isContained(event) ||
        (event.action ?? '').toUpperCase() == 'RESOLVED') {
      return false;
    }

    final rule = (event.ruleName ?? '').toLowerCase();
    final category = event.category.toUpperCase();

    final correlatedThreat =
        rule.contains('high confidence correlated endpoint threat');

    final threatIntelMatch = rule.contains('threat intelligence match');

    final yaraDetection = rule.contains('yara') && event.hasFileEvidence;

    final suspiciousOutbound =
        category == 'SUSPICIOUS_OUTBOUND_CONNECTION' && event.confidence >= 90;

    final confirmedIncident =
        event.confirmed || category == 'CONFIRMED_INCIDENT';

    final criticalThreat =
        event.severity.toUpperCase() == 'CRITICAL' && event.confidence >= 90;

    return correlatedThreat ||
        threatIntelMatch ||
        yaraDetection ||
        suspiciousOutbound ||
        confirmedIncident ||
        criticalThreat;
  }

  static int _globalRisk(List<SecurityEvent> events) {
    var highest = 0;

    for (final event in events) {
      if (!_isActiveThreat(event)) {
        continue;
      }

      var candidate = event.threatScore;

      if ((event.ruleName ?? '')
          .toLowerCase()
          .contains('high confidence correlated endpoint threat')) {
        candidate = event.confidence.round();
      }

      if (candidate > highest) {
        highest = candidate;
      }
    }

    return highest.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SecurityEvent>>(
      stream: Level6EventService.instance.watchEvents(),
      builder: (context, snapshot) {
        final events = snapshot.data ?? const <SecurityEvent>[];

        final active = events.where(_isActiveThreat).length;
        final critical = events.where((event) {
          return _isActiveThreat(event) && event.severity == 'CRITICAL';
        }).length;
        final contained = events.where(_isContained).length;
        final risk = _globalRisk(events);

        final data = [
          (
            risk.toString(),
            'GLOBAL RISK',
            Icons.public_rounded,
            GenesisColors.cyan,
          ),
          (
            active.toString(),
            'ACTIVE THREATS',
            Icons.warning_amber_rounded,
            GenesisColors.danger,
          ),
          (
            critical.toString(),
            'CRITICAL',
            Icons.gps_fixed_rounded,
            GenesisColors.danger,
          ),
          (
            contained.toString(),
            'CONTAINED',
            Icons.bar_chart_rounded,
            GenesisColors.emerald,
          ),
        ];

        return Row(
          children: [
            for (var index = 0; index < data.length; index++) ...[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: GenesisColors.panelRaised,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: data[index].$4,
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: data[index].$4.withValues(alpha: .18),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        data[index].$3,
                        color: data[index].$4,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data[index].$1,
                              style: TextStyle(
                                color: data[index].$4,
                                fontSize: 22,
                                height: 1,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data[index].$2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: GenesisColors.text,
                                fontSize: 7,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (index != data.length - 1) const SizedBox(width: 8),
            ],
          ],
        );
      },
    );
  }
}

class _MobileThreatMatrix extends StatelessWidget {
  const _MobileThreatMatrix({required this.pulse});

  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.public_rounded,
                color: GenesisColors.cyan,
                size: 20,
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GLOBAL THREAT MATRIX',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: GenesisColors.text,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'VERIFIED TELEMETRY • GLOBAL COVERAGE',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: GenesisColors.muted,
                        fontSize: 6,
                        letterSpacing: .35,
                      ),
                    ),
                  ],
                ),
              ),
              const _MiniPill(
                'LIVE',
                GenesisColors.emerald,
              ),
              const SizedBox(width: 5),
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 28,
                    height: 28,
                  ),
                  tooltip: 'Open full threat map',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => Scaffold(
                          backgroundColor: GenesisColors.voidBlack,
                          body: SafeArea(
                            child: const ActiveThreatsScreen(),
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.open_in_full_rounded,
                    color: GenesisColors.cyan,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF03162A),
                  border: Border.all(
                    color: GenesisColors.cyan.withValues(alpha: .35),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DetailedWorldMap(pulse: pulse),
              ),
            ),
          ),
          const SizedBox(height: 7),
          const _LiveMobileThreatStats(),
          const SizedBox(height: 7),
          const Row(
            children: [
              Expanded(
                child: _MobileLegendItem(
                  'ACTIVE THREAT',
                  GenesisColors.danger,
                ),
              ),
              Expanded(
                child: _MobileLegendItem(
                  'MONITORED',
                  GenesisColors.warning,
                ),
              ),
              Expanded(
                child: _MobileLegendItem(
                  'SECURE NODE',
                  GenesisColors.cyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveMobileThreatStats extends StatelessWidget {
  const _LiveMobileThreatStats();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SecurityEvent>>(
      stream: Level6EventService.instance.watchEvents(),
      builder: (context, snapshot) {
        final events = snapshot.data ?? const <SecurityEvent>[];

        final detections =
            events.where((event) => event.category != 'GLOBAL_TRAFFIC').length;

        final blocked = events.where((event) {
          return event.category == 'WAF_BLOCKED' ||
              event.category == 'BOT_BLOCKED' ||
              event.category == 'RATE_LIMITED' ||
              event.category == 'DDOS_MITIGATED';
        }).length;

        final incidents =
            events.where((event) => event.isConfirmedIncident).length;

        return Row(
          children: [
            Expanded(
              child: _MobileThreatStat(
                value: detections.toString(),
                label: 'EVENTS',
                color: GenesisColors.cyan,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _MobileThreatStat(
                value: blocked.toString(),
                label: 'BLOCKED',
                color: GenesisColors.warning,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _MobileThreatStat(
                value: incidents.toString(),
                label: 'INCIDENTS',
                color: GenesisColors.danger,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MobileThreatStat extends StatelessWidget {
  const _MobileThreatStat({
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
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: GenesisColors.panelRaised,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: color.withValues(alpha: .55),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: GenesisColors.text,
                fontSize: 6,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileLegendItem extends StatelessWidget {
  const _MobileLegendItem(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.circle,
          color: color,
          size: 7,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: GenesisColors.muted,
              fontSize: 5.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ThreatMatrix extends StatelessWidget {
  const _ThreatMatrix({required this.pulse});
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(children: [
        const _PanelHeader(
          icon: Icons.gps_fixed_rounded,
          title: 'GLOBAL THREAT MATRIX',
          subtitle: 'VERIFIED TELEMETRY - NO SIMULATED THREATS',
          trailing: _LiveControls(),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Row(children: [
            const SizedBox(width: 80, child: _ThreatLegend()),
            Expanded(
              child: DetailedWorldMap(pulse: pulse),
            ),
            const SizedBox(width: 120, child: _AttackStats()),
          ]),
        ),
      ]),
    );
  }
}

class _LiveControls extends StatelessWidget {
  const _LiveControls();
  @override
  Widget build(BuildContext context) => const Row(children: [
        _MiniPill('LIVE RADAR', GenesisColors.emerald),
        SizedBox(width: 5),
        _MiniPill('24H', GenesisColors.cyan),
        SizedBox(width: 5),
        _MiniPill('7D', GenesisColors.muted),
        SizedBox(width: 5),
        _MiniPill('THREAT LAYERS', GenesisColors.muted),
      ]);
}

class _ThreatLegend extends StatelessWidget {
  const _ThreatLegend();
  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Legend('CRITICAL', GenesisColors.danger),
          _Legend('HIGH', Color(0xFFFF8B38)),
          _Legend('MEDIUM', GenesisColors.warning),
          _Legend('LOW', GenesisColors.emerald),
          _Legend('INFO', GenesisColors.cyan),
          Spacer(),
          Text('CLOUDFLARE RADAR\nVERIFIED ROUTES\nLIVE TELEMETRY',
              style: TextStyle(
                  color: GenesisColors.muted, fontSize: 6, height: 1.6)),
        ],
      );
}

class _Legend extends StatelessWidget {
  const _Legend(this.label, this.color);
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Icon(Icons.circle, color: color, size: 8),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(color: GenesisColors.text, fontSize: 7)),
        ]),
      );
}

class _AttackStats extends StatelessWidget {
  const _AttackStats();

  int _count(List<SecurityEvent> events, String category) {
    return events.where((event) => event.category == category).length;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SecurityEvent>>(
      stream: Level6EventService.instance.watchEvents(),
      builder: (context, snapshot) {
        final events = snapshot.data ?? const <SecurityEvent>[];

        final data = [
          ('WAF BLOCKED', _count(events, 'WAF_BLOCKED').toString()),
          ('BOT BLOCKED', _count(events, 'BOT_BLOCKED').toString()),
          ('RATE LIMITED', _count(events, 'RATE_LIMITED').toString()),
          ('ENDPOINT', _count(events, 'ENDPOINT_ALERT').toString()),
          (
            'HIGH CONF.',
            _count(events, 'HIGH_CONFIDENCE_THREAT').toString(),
          ),
          (
            'CONFIRMED',
            events
                .where((event) => event.isConfirmedIncident)
                .length
                .toString(),
          ),
        ];

        return Column(
          children: [
            for (final item in data)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: GenesisColors.border),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$1,
                        style: const TextStyle(
                          color: GenesisColors.muted,
                          fontSize: 6,
                        ),
                      ),
                      Text(
                        item.$2,
                        style: const TextStyle(
                          color: GenesisColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RegionLabel extends StatelessWidget {
  const _RegionLabel(this.title, this.detail);
  final String title;
  final String detail;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: GenesisColors.text,
                  fontSize: 9,
                  fontWeight: FontWeight.w900)),
          Text(detail,
              style: const TextStyle(color: GenesisColors.muted, fontSize: 7)),
        ],
      );
}

class _IntelligenceStream extends StatelessWidget {
  const _IntelligenceStream();

  String _timeLabel(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'CRITICAL':
        return GenesisColors.danger;
      case 'HIGH':
        return const Color(0xFFFF8B38);
      case 'MEDIUM':
        return GenesisColors.warning;
      case 'LOW':
        return GenesisColors.emerald;
      default:
        return GenesisColors.cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        children: [
          const _PanelHeader(
            icon: Icons.stream_rounded,
            title: 'LIVE INTELLIGENCE STREAM',
            subtitle: 'VERIFIED LEVEL 6 SECURITY EVENTS ONLY',
          ),
          const SizedBox(height: 6),
          Expanded(
            child: StreamBuilder<List<SecurityEvent>>(
              stream: Level6EventService.instance.watchEvents(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: GenesisColors.danger,
                          size: 30,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'LEVEL 6 FEED ERROR',
                          style: TextStyle(
                            color: GenesisColors.text,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final events = snapshot.data ?? const <SecurityEvent>[];

                if (events.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: GenesisColors.emerald,
                          size: 32,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'NO CURRENT SECURITY DETECTIONS',
                          style: TextStyle(
                            color: GenesisColors.text,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'LEVEL 6 COLLECTOR CONNECTED - LIVE EVENT FEED ACTIVE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: GenesisColors.muted,
                            fontSize: 7,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final visible = events.take(8).toList();

                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: GenesisColors.border,
                  ),
                  itemBuilder: (context, index) {
                    final event = visible[index];
                    final detail = [
                      if (event.sourceCountry != null) event.sourceCountry!,
                      if (event.targetAssetId != null) event.targetAssetId!,
                      if (event.action != null) event.action!,
                    ].join(' / ');

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 7,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 7,
                            color: _severityColor(event.severity),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        (event.ruleName?.trim().isNotEmpty ==
                                                true
                                            ? event.ruleName!
                                            : event.category
                                                .replaceAll('_', ' ')),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: GenesisColors.text,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _timeLabel(event.occurredAt),
                                      style: const TextStyle(
                                        color: GenesisColors.muted,
                                        fontSize: 6,
                                      ),
                                    ),
                                  ],
                                ),
                                if (detail.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    detail,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: GenesisColors.muted,
                                      fontSize: 6.5,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 2),
                                Text(
                                  'SEVERITY ${event.severity}  |  SCORE ${event.threatScore}  |  CONFIDENCE ${event.confidence.toStringAsFixed(0)}%',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: _severityColor(event.severity),
                                    fontSize: 6,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentDukePanel extends StatelessWidget {
  const _AgentDukePanel();

  @override
  Widget build(BuildContext context) => _Panel(
        child: Column(
          children: [
            const _PanelHeader(
              icon: Icons.hub_rounded,
              title: 'AGENT DUKE AI',
              subtitle: 'AI COMMAND CORE • AUTONOMOUS THREAT HUNTING',
            ),
            const Expanded(
              child: Row(
                children: [
                  DukeIntelligenceCore(),
                  SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CheckLine('THREAT DETECTION', 'ACTIVE'),
                        _CheckLine('ANOMALY ANALYSIS', 'ACTIVE'),
                        _CheckLine('AUTONOMOUS CONTAINMENT', 'ACTIVE'),
                        _CheckLine('PREDICTIVE INTELLIGENCE', 'ACTIVE'),
                        _CheckLine('PLAYBOOK EXECUTION', 'READY'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 23,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: GenesisColors.cyan.withValues(alpha: .025),
                border: Border.all(color: GenesisColors.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Text(
                    'Ask Agent Duke...',
                    style: TextStyle(
                      color: GenesisColors.muted,
                      fontSize: 8,
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.graphic_eq_rounded,
                    color: GenesisColors.cyan,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _PrincePanel extends StatelessWidget {
  const _PrincePanel();
  @override
  Widget build(BuildContext context) => _Panel(
        borderColor: GenesisColors.goldSoft,
        child: Column(children: [
          const _PanelHeader(
              icon: Icons.workspace_premium_rounded,
              title: 'PRINCE X',
              subtitle: 'FOUNDER COMMAND AUTHORITY',
              iconColor: GenesisColors.gold),
          const Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                _CheckLine('FACE ID BIOMETRIC', 'VERIFIED'),
                _CheckLine('HARDWARE KEY', 'VERIFIED'),
                _CheckLine('COMMAND SIGNING', 'ENABLED'),
                _CheckLine('SESSION ENCRYPTED', 'AES-512'),
                _CheckLine('AUTHORITY LEVEL', 'FOUNDER (LEVEL 6)'),
              ])),
          SizedBox(
              width: double.infinity,
              height: 25,
              child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const Scaffold(
                          backgroundColor: GenesisColors.voidBlack,
                          body: SafeArea(
                            child: _BiometricPanel(),
                          ),
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                      backgroundColor:
                          GenesisColors.gold.withValues(alpha: .14),
                      foregroundColor: GenesisColors.gold,
                      side: const BorderSide(color: GenesisColors.gold)),
                  child: const Text('AUTHORIZE OPERATION',
                      style: TextStyle(
                          fontSize: 9, fontWeight: FontWeight.w900)))),
        ]),
      );
}

class _BiometricPanel extends StatelessWidget {
  const _BiometricPanel({this.onTap});

  final VoidCallback? onTap;

  void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _authorizeBiometric(BuildContext context) async {
    if (kIsWeb) {
      _notify(
        context,
        'Native Face ID is available in the installed iPhone app, not the web preview.',
      );
      return;
    }

    final auth = LocalAuthentication();

    try {
      final supported = await auth.isDeviceSupported();
      final canCheck = await auth.canCheckBiometrics;

      if (!supported || !canCheck) {
        await CipherBackendService.instance.recordBiometricAssurance(
          biometricType: 'unavailable',
          result: 'unavailable',
          reason: 'Device biometric authentication is unavailable.',
        );

        if (!context.mounted) return;

        _notify(
          context,
          'Biometric authentication is not available on this device.',
        );
        return;
      }

      final available = await auth.getAvailableBiometrics();

      String biometricType = 'device_biometric';

      if (available.contains(BiometricType.face)) {
        biometricType = 'face_id';
      } else if (available.contains(BiometricType.fingerprint)) {
        biometricType = 'fingerprint';
      } else if (available.contains(BiometricType.iris)) {
        biometricType = 'iris';
      } else if (available.isNotEmpty) {
        biometricType = available.first.name;
      }

      final verified = await auth.authenticate(
        localizedReason:
            'Verify your identity to authorize this 999 Cipher operation.',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      await CipherBackendService.instance.recordBiometricAssurance(
        biometricType: biometricType,
        result: verified ? 'verified' : 'failed',
        reason: verified
            ? 'Native biometric authorization completed successfully.'
            : 'Native biometric authorization was denied or cancelled.',
      );

      if (!context.mounted) return;

      _notify(
        context,
        verified
            ? 'Biometric identity verified and recorded.'
            : 'Biometric authorization was not completed.',
      );
    } catch (error) {
      try {
        await CipherBackendService.instance.recordBiometricAssurance(
          biometricType: 'device_biometric',
          result: 'error',
          reason: error.toString(),
        );
      } catch (_) {}

      if (!context.mounted) return;

      _notify(
        context,
        'Biometric authorization failed: $error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final expanded = constraints.maxHeight >= 430;

        if (!expanded) {
          return _CompactBiometricPanel(onTap: onTap);
        }

        final narrow = constraints.maxWidth < 720;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(2),
          child: Column(
            children: [
              const _Panel(
                child: _PanelHeader(
                  icon: Icons.fingerprint_rounded,
                  title: 'IDENTITY & BIOMETRIC ASSURANCE',
                  subtitle: 'CONTINUOUS ZERO-TRUST AUTHENTICATION',
                  trailing: _MiniPill(
                    'IDENTITY VERIFIED',
                    GenesisColors.emerald,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (narrow) ...[
                const SizedBox(
                  height: 255,
                  child: _BiometricScannerCard(),
                ),
                const SizedBox(height: 10),
                const SizedBox(
                  height: 155,
                  child: _AssuranceScoreCard(),
                ),
                const SizedBox(height: 10),
                const SizedBox(
                  height: 175,
                  child: _BiometricStackCard(),
                ),
                const SizedBox(height: 10),
                const SizedBox(
                  height: 245,
                  child: _SessionIntelligenceCard(),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 255,
                  child: _ActiveSessionsCard(
                    onRevoke: () => _notify(
                      context,
                      'Session revocation requires founder authorization.',
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  height: 310,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Expanded(
                        flex: 5,
                        child: _BiometricScannerCard(),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            Expanded(child: _AssuranceScoreCard()),
                            SizedBox(height: 10),
                            Expanded(child: _BiometricStackCard()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 245,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Expanded(child: _SessionIntelligenceCard()),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActiveSessionsCard(
                          onRevoke: () => _notify(
                            context,
                            'Session revocation requires founder authorization.',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              _SecurityActionCard(
                icon: Icons.enhanced_encryption_rounded,
                title: 'CRYPTOGRAPHIC COMMAND AUTHORIZATION',
                subtitle: 'SIGN AND AUTHORIZE SENSITIVE OPERATIONS',
                action: 'AUTHORIZE OPERATION',
                color: GenesisColors.emerald,
                onPressed: () => _authorizeBiometric(context),
              ),
              const SizedBox(height: 10),
              const _Panel(
                child: Row(
                  children: [
                    Icon(
                      Icons.storage_rounded,
                      color: GenesisColors.cyan,
                      size: 27,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TAMPER-EVIDENT AUDIT STATUS',
                            style: TextStyle(
                              color: GenesisColors.text,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'ALL EVENTS CRYPTOGRAPHICALLY SEALED',
                            style: TextStyle(
                              color: GenesisColors.cyan,
                              fontSize: 7,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _MiniPill(
                      'AUDIT CHAIN: SEALED',
                      GenesisColors.emerald,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _SecurityActionCard(
                icon: Icons.warning_amber_rounded,
                title: 'SECURITY LOCKDOWN',
                subtitle: 'IMMEDIATELY REVOKE ACCESS AND ISOLATE',
                action: 'ACTIVATE',
                color: GenesisColors.danger,
                onPressed: () => _showLockdownDialog(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLockdownDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('SECURITY LOCKDOWN'),
        content: const Text(
          'This control will revoke active sessions and isolate protected systems. Founder authorization is required.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: GenesisColors.danger,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              _notify(
                context,
                'Lockdown request recorded. Live services are not connected yet.',
              );
            },
            child: const Text('AUTHORIZE LOCKDOWN'),
          ),
        ],
      ),
    );
  }
}

class _CompactBiometricPanel extends StatelessWidget {
  const _CompactBiometricPanel({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final panel = const _Panel(
      child: Column(
        children: [
          _PanelHeader(
            icon: Icons.fingerprint_rounded,
            title: 'IDENTITY & BIOMETRIC ASSURANCE',
            subtitle: 'CONTINUOUS AUTHENTICATION',
          ),
          Expanded(
            child: Row(
              children: [
                BiometricWireframe(),
                SizedBox(width: 6),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CheckLine('FACE + LIVENESS', 'VERIFIED'),
                      _CheckLine('VOICE AUTH', 'VERIFIED'),
                      _CheckLine('PASSKEY', 'VERIFIED'),
                      _CheckLine('DEVICE TRUST', 'VERIFIED'),
                      _CheckLine('SESSION RISK', 'LOW'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return panel;

    return Semantics(
      button: true,
      label: 'Open Identity and Biometrics',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: panel,
        ),
      ),
    );
  }
}

class _BiometricScannerCard extends StatelessWidget {
  const _BiometricScannerCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Stack(
        children: [
          const Positioned.fill(
            child: Opacity(
              opacity: .9,
              child: BiometricWireframe(),
            ),
          ),
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: GenesisColors.emerald.withValues(alpha: .12),
                border: Border.all(color: GenesisColors.emerald),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'LIVE BIOMETRIC SCAN',
                style: TextStyle(
                  color: GenesisColors.emerald,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 8,
            right: 8,
            bottom: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MiniPill('LIVENESS: PASS', GenesisColors.emerald),
                _MiniPill('DEEPFAKE: CLEAR', GenesisColors.cyan),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssuranceScoreCard extends StatelessWidget {
  const _AssuranceScoreCard();

  @override
  Widget build(BuildContext context) {
    return const _Panel(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ASSURANCE SCORE',
            style: TextStyle(
              color: GenesisColors.cyan,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '97 / 100',
            style: TextStyle(
              color: GenesisColors.emerald,
              fontSize: 39,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 9),
          _MiniPill('IDENTITY VERIFIED', GenesisColors.emerald),
        ],
      ),
    );
  }
}

class _BiometricStackCard extends StatelessWidget {
  const _BiometricStackCard();

  @override
  Widget build(BuildContext context) {
    return const _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BIOMETRIC STACK',
            style: TextStyle(
              color: GenesisColors.cyan,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 5),
          _CheckLine('FACE + LIVENESS', 'VERIFIED'),
          _CheckLine('VOICE AUTHENTICATION', 'VERIFIED'),
          _CheckLine('PASSKEY', 'VERIFIED'),
          _CheckLine('HARDWARE KEY', 'VERIFIED'),
        ],
      ),
    );
  }
}

class _SessionIntelligenceCard extends StatelessWidget {
  const _SessionIntelligenceCard();

  @override
  Widget build(BuildContext context) {
    return const _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            icon: Icons.insights_rounded,
            title: 'SESSION INTELLIGENCE',
            subtitle: 'CONTINUOUS RISK EVALUATION',
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BioStatusLine(
                  Icons.shield_outlined,
                  'SESSION RISK',
                  'LOW',
                ),
                _BioStatusLine(
                  Icons.laptop_mac_rounded,
                  'DEVICE TRUST',
                  'VERIFIED',
                ),
                _BioStatusLine(
                  Icons.location_on_outlined,
                  'LOCATION',
                  'TRUSTED',
                ),
                _BioStatusLine(
                  Icons.bar_chart_rounded,
                  'BEHAVIOR',
                  'NORMAL',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveSessionsCard extends StatelessWidget {
  const _ActiveSessionsCard({required this.onRevoke});

  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeader(
            icon: Icons.devices_rounded,
            title: 'ACTIVE SESSIONS',
            subtitle: '2 TRUSTED DEVICES',
          ),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TrustedDeviceRow(
                  icon: Icons.laptop_mac_rounded,
                  name: 'MacBook Pro',
                  platform: 'macOS • CURRENT SESSION',
                ),
                SizedBox(height: 7),
                _TrustedDeviceRow(
                  icon: Icons.phone_iphone_rounded,
                  name: 'iPhone',
                  platform: 'iOS • REMOTE SESSION',
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 34,
            child: OutlinedButton.icon(
              onPressed: onRevoke,
              icon: const Icon(Icons.delete_outline_rounded, size: 16),
              label: const Text('REVOKE SELECTED SESSION'),
              style: OutlinedButton.styleFrom(
                foregroundColor: GenesisColors.danger,
                side: const BorderSide(color: GenesisColors.danger),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BioStatusLine extends StatelessWidget {
  const _BioStatusLine(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: GenesisColors.cyan, size: 17),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: GenesisColors.muted,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: GenesisColors.emerald,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustedDeviceRow extends StatelessWidget {
  const _TrustedDeviceRow({
    required this.icon,
    required this.name,
    required this.platform,
  });

  final IconData icon;
  final String name;
  final String platform;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: GenesisColors.cyan, size: 25),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: GenesisColors.text,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                platform,
                style: const TextStyle(
                  color: GenesisColors.muted,
                  fontSize: 7,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.circle,
          color: GenesisColors.emerald,
          size: 8,
        ),
        const SizedBox(width: 5),
        const Text(
          'TRUSTED',
          style: TextStyle(
            color: GenesisColors.emerald,
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SecurityActionCard extends StatelessWidget {
  const _SecurityActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String action;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      borderColor: color,
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: GenesisColors.text,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color,
                    fontSize: 7,
                    letterSpacing: .8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: color.withValues(alpha: .16),
              foregroundColor: color,
              side: BorderSide(color: color),
            ),
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: Text(
              action,
              style: const TextStyle(
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

class _EndpointPanel extends StatelessWidget {
  const _EndpointPanel();
  @override
  Widget build(BuildContext context) => _Panel(
        child: Column(children: [
          const _PanelHeader(
              icon: Icons.dns_rounded,
              title: 'ENDPOINT FLEET',
              subtitle: 'PROTECTED ASSET HEALTH'),
          Expanded(
              child: Row(children: [
            const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('—',
                      style: TextStyle(
                          color: GenesisColors.text,
                          fontSize: 25,
                          fontWeight: FontWeight.w900)),
                  Text('ENDPOINTS',
                      style:
                          TextStyle(color: GenesisColors.muted, fontSize: 8)),
                ]),
            const Spacer(),
            Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: GenesisColors.emerald, width: 7)),
                child: const Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text('99.2%',
                          style: TextStyle(
                              color: GenesisColors.text,
                              fontWeight: FontWeight.w900)),
                      Text('HEALTHY',
                          style: TextStyle(
                              color: GenesisColors.muted, fontSize: 6))
                    ]))),
            const Spacer(),
            const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DotValue('—', 'HEALTHY', GenesisColors.emerald),
                  _DotValue('—', 'DEGRADED', GenesisColors.warning),
                  _DotValue('—', 'ISOLATED', GenesisColors.danger),
                ]),
          ])),
          const _BarChart(color: GenesisColors.cyan),
        ]),
      );
}

class _TrafficPanel extends StatelessWidget {
  const _TrafficPanel();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SecurityEvent>>(
      stream: Level6EventService.instance.watchEvents(),
      builder: (context, snapshot) {
        final events = snapshot.data ?? const <SecurityEvent>[];
        final now = DateTime.now();

        final recent = events.where((event) {
          return now.difference(event.occurredAt.toLocal()).inMinutes <= 10;
        }).toList();

        final globalTraffic =
            recent.where((event) => event.isGlobalTraffic).length;

        final threatTraffic = recent.where((event) {
          final severity = event.severity.toUpperCase();
          final action = (event.action ?? '').toUpperCase();
          return action != 'RESOLVED' &&
              (event.confirmed || severity == 'HIGH' || severity == 'CRITICAL');
        }).length;

        final endpointSignals = recent.where((event) {
          return (event.endpointId ?? '').trim().isNotEmpty ||
              event.hasFileEvidence ||
              event.hasProcessEvidence;
        }).length;

        final latest =
            events.isEmpty ? null : events.first.occurredAt.toLocal();

        final connected = snapshot.hasData && !snapshot.hasError;

        return _Panel(
          child: Column(
            children: [
              _PanelHeader(
                icon: Icons.timeline_rounded,
                title: 'NETWORK TRAFFIC ANALYTICS',
                subtitle: connected
                    ? 'LIVE LEVEL 6 EVENT FLOW CONNECTED'
                    : snapshot.hasError
                        ? 'LIVE SOURCE ERROR'
                        : 'CONNECTING TO LIVE EVENT FLOW',
                trailing: _MiniPill(
                  connected ? 'LIVE' : 'SYNC',
                  connected ? GenesisColors.emerald : GenesisColors.warning,
                ),
              ),
              const SizedBox(height: 7),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: GenesisColors.cyan.withValues(alpha: .20),
                          ),
                          color: const Color(0xFF041225).withValues(alpha: .38),
                        ),
                        child: CustomPaint(
                          painter: _LiveTrafficPainter(events: recent),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    SizedBox(
                      width: 112,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LiveMetricTile(
                            icon: Icons.public_rounded,
                            label: 'GLOBAL FLOW',
                            value: '$globalTraffic',
                            color: GenesisColors.cyan,
                          ),
                          _LiveMetricTile(
                            icon: Icons.warning_amber_rounded,
                            label: 'THREAT FLOW',
                            value: '$threatTraffic',
                            color: GenesisColors.danger,
                          ),
                          _LiveMetricTile(
                            icon: Icons.memory_rounded,
                            label: 'ENDPOINT',
                            value: '$endpointSignals',
                            color: const Color(0xFF9B63FF),
                          ),
                          _LiveMetricTile(
                            icon: Icons.schedule_rounded,
                            label: 'LAST EVENT',
                            value:
                                latest == null ? '--:--' : _cipherClock(latest),
                            color: GenesisColors.emerald,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CameraPanel extends StatelessWidget {
  const _CameraPanel();

  static const _feeds = [
    ('HQ ENTRY', 0),
    ('SERVER ROOM', 1),
    ('OPS FLOOR', 2),
    ('PERIMETER', 3),
  ];

  @override
  Widget build(BuildContext context) => _Panel(
        child: Column(
          children: [
            const _PanelHeader(
              icon: Icons.videocam_rounded,
              title: 'CAMERAS & ALARMS',
              subtitle: 'PHYSICAL SECURITY INTEGRATION',
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Row(
                children: [
                  for (final feed in _feeds)
                    Expanded(
                      child: feed.$2 == 0
                          ? const LiveCameraFeed(name: 'MACBOOK CAMERA')
                          : SecurityCameraFeed(
                              name: feed.$1,
                              index: feed.$2,
                            ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _RecoveryPanel extends StatelessWidget {
  const _RecoveryPanel();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SecurityEvent>>(
      stream: Level6EventService.instance.watchEvents(),
      builder: (context, snapshot) {
        final events = snapshot.data ?? const <SecurityEvent>[];

        final unresolved = events.where((event) {
          return (event.action ?? '').toUpperCase() != 'RESOLVED';
        }).toList();

        final critical = unresolved.where((event) {
          return event.severity.toUpperCase() == 'CRITICAL';
        }).length;

        final high = unresolved.where((event) {
          return event.severity.toUpperCase() == 'HIGH';
        }).length;

        final confirmed = unresolved.where((event) {
          return event.confirmed;
        }).length;

        final connected = snapshot.hasData && !snapshot.hasError;

        var readiness = connected ? 100 : 0;
        readiness -= critical * 20;
        readiness -= high * 8;
        readiness -= confirmed * 5;
        readiness = readiness.clamp(0, 100);

        final latest =
            events.isEmpty ? null : events.first.occurredAt.toLocal();

        return _Panel(
          child: Column(
            children: [
              _PanelHeader(
                icon: Icons.settings_backup_restore_rounded,
                title: 'RECOVERY READINESS',
                subtitle: connected
                    ? 'LIVE SECURITY RESILIENCE TELEMETRY'
                    : 'CONNECTING TO RESILIENCE TELEMETRY',
                trailing: _MiniPill(
                  connected ? 'OPERATIONAL' : 'SYNC',
                  connected ? GenesisColors.emerald : GenesisColors.warning,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 102,
                      child: Center(
                        child: _LiveReadinessRing(
                          value: readiness,
                          connected: connected,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _RecoveryLiveRow(
                            'LEVEL 6 STREAM',
                            connected ? 'CONNECTED' : 'CONNECTING',
                            connected
                                ? GenesisColors.emerald
                                : GenesisColors.warning,
                          ),
                          _RecoveryLiveRow(
                            'UNRESOLVED',
                            '${unresolved.length}',
                            unresolved.isEmpty
                                ? GenesisColors.emerald
                                : GenesisColors.warning,
                          ),
                          _RecoveryLiveRow(
                            'CRITICAL',
                            '$critical',
                            critical == 0
                                ? GenesisColors.emerald
                                : GenesisColors.danger,
                          ),
                          _RecoveryLiveRow(
                            'HIGH',
                            '$high',
                            high == 0
                                ? GenesisColors.emerald
                                : GenesisColors.warning,
                          ),
                          _RecoveryLiveRow(
                            'LAST TELEMETRY',
                            latest == null ? '--:--' : _cipherClock(latest),
                            GenesisColors.cyan,
                          ),
                          _RecoveryLiveRow(
                            'BACKUP / DR FEED',
                            'NOT CONFIGURED',
                            GenesisColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EvidencePanel extends StatelessWidget {
  const _EvidencePanel();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SecurityEvent>>(
      stream: Level6EventService.instance.watchEvents(),
      builder: (context, snapshot) {
        final events = snapshot.data ?? const <SecurityEvent>[];

        final fileEvents =
            events.where((event) => event.hasFileEvidence).toList();

        final processEvents =
            events.where((event) => event.hasProcessEvidence).toList();

        final evidenceEvents = events.where((event) {
          return event.hasFileEvidence || event.hasProcessEvidence;
        }).toList();

        final openCases = events.where((event) {
          final severity = event.severity.toUpperCase();
          final action = (event.action ?? '').toUpperCase();

          return action != 'RESOLVED' &&
              (event.confirmed || severity == 'HIGH' || severity == 'CRITICAL');
        }).length;

        final latestEvidence = evidenceEvents.isEmpty
            ? null
            : evidenceEvents.first.occurredAt.toLocal();

        final connected = snapshot.hasData && !snapshot.hasError;

        return _Panel(
          child: Column(
            children: [
              _PanelHeader(
                icon: Icons.inventory_2_rounded,
                title: 'EVIDENCE VAULT',
                subtitle: connected
                    ? 'LIVE EVENT EVIDENCE • CHAIN OF CUSTODY'
                    : 'CONNECTING TO EVIDENCE TELEMETRY',
                trailing: _MiniPill(
                  connected ? 'INGESTING' : 'SYNC',
                  connected ? GenesisColors.emerald : GenesisColors.warning,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: GenesisColors.cyan.withValues(alpha: .20),
                          ),
                          color: const Color(0xFF041225).withValues(alpha: .35),
                        ),
                        child: CustomPaint(
                          painter: _LiveEvidencePainter(events: evidenceEvents),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    SizedBox(
                      width: 116,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LiveMetricTile(
                            icon: Icons.description_outlined,
                            label: 'FILE EVENTS',
                            value: '${fileEvents.length}',
                            color: GenesisColors.cyan,
                          ),
                          _LiveMetricTile(
                            icon: Icons.memory_rounded,
                            label: 'PROCESS',
                            value: '${processEvents.length}',
                            color: const Color(0xFF9B63FF),
                          ),
                          _LiveMetricTile(
                            icon: Icons.folder_open_rounded,
                            label: 'OPEN CASES',
                            value: '$openCases',
                            color: openCases == 0
                                ? GenesisColors.emerald
                                : GenesisColors.warning,
                          ),
                          _LiveMetricTile(
                            icon: Icons.sync_rounded,
                            label: 'LAST INGEST',
                            value: latestEvidence == null
                                ? '--:--'
                                : _cipherClock(latestEvidence),
                            color: GenesisColors.emerald,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LiveMetricTile extends StatelessWidget {
  const _LiveMetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: .25),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: color.withValues(alpha: .24),
              ),
              color: color.withValues(alpha: .055),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: .06),
                  blurRadius: 9,
                ),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: constraints.maxWidth > 10
                    ? constraints.maxWidth - 10
                    : constraints.maxWidth,
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 12,
                      color: color,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: GenesisColors.muted,
                              fontSize: 5.6,
                              height: 1,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .35,
                            ),
                          ),
                          const SizedBox(height: .25),
                          Text(
                            value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: color,
                              fontSize: 9.2,
                              height: 1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecoveryLiveRow extends StatelessWidget {
  const _RecoveryLiveRow(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: color.withValues(alpha: .035),
          border: Border.all(
            color: color.withValues(alpha: .12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 8,
              color: color,
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: 5,
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: GenesisColors.muted,
                  fontSize: 5.2,
                  height: .95,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 1),
            Expanded(
              flex: 4,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  maxLines: 1,
                  style: TextStyle(
                    color: color,
                    fontSize: 6.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveReadinessRing extends StatelessWidget {
  const _LiveReadinessRing({
    required this.value,
    required this.connected,
  });

  final int value;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    final color = !connected
        ? GenesisColors.warning
        : value >= 90
            ? GenesisColors.emerald
            : value >= 70
                ? GenesisColors.warning
                : GenesisColors.danger;

    return SizedBox(
      width: 86,
      height: 86,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: value / 100,
              strokeWidth: 7,
              backgroundColor: color.withValues(alpha: .12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: .06),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: .16),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$value%',
                  style: TextStyle(
                    color: color,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'LIVE SCORE',
                  style: TextStyle(
                    color: GenesisColors.muted,
                    fontSize: 5.5,
                    fontWeight: FontWeight.w700,
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

String _cipherClock(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

class _LiveTrafficPainter extends CustomPainter {
  const _LiveTrafficPainter({required this.events});

  final List<SecurityEvent> events;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = GenesisColors.border.withValues(alpha: .20)
      ..strokeWidth = .5;

    for (var i = 1; i < 6; i++) {
      final y = size.height * i / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    for (var i = 1; i < 10; i++) {
      final x = size.width * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }

    if (events.isEmpty) {
      return;
    }

    final now = DateTime.now();
    const bucketCount = 12;

    final global = List<int>.filled(bucketCount, 0);
    final threats = List<int>.filled(bucketCount, 0);
    final endpoints = List<int>.filled(bucketCount, 0);

    for (final event in events) {
      final ageSeconds = now.difference(event.occurredAt.toLocal()).inSeconds;

      if (ageSeconds < 0 || ageSeconds > 600) {
        continue;
      }

      var bucket = bucketCount - 1 - ((ageSeconds / 600) * bucketCount).floor();

      bucket = bucket.clamp(0, bucketCount - 1);

      if (event.isGlobalTraffic) {
        global[bucket]++;
      }

      final severity = event.severity.toUpperCase();
      final action = (event.action ?? '').toUpperCase();

      if (action != 'RESOLVED' &&
          (event.confirmed || severity == 'HIGH' || severity == 'CRITICAL')) {
        threats[bucket]++;
      }

      if ((event.endpointId ?? '').trim().isNotEmpty ||
          event.hasFileEvidence ||
          event.hasProcessEvidence) {
        endpoints[bucket]++;
      }
    }

    final maxValue = [
      ...global,
      ...threats,
      ...endpoints,
      1,
    ].reduce(math.max);

    void series(List<int> data, Color color) {
      final path = Path();

      for (var i = 0; i < data.length; i++) {
        final x = i * size.width / (data.length - 1);
        final y = size.height - 8 - ((data[i] / maxValue) * (size.height - 16));

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: .18)
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = 1.7
          ..style = PaintingStyle.stroke,
      );
    }

    series(global, GenesisColors.cyan);
    series(threats, GenesisColors.danger);
    series(endpoints, const Color(0xFF9B63FF));
  }

  @override
  bool shouldRepaint(covariant _LiveTrafficPainter oldDelegate) => true;
}

class _LiveEvidencePainter extends CustomPainter {
  const _LiveEvidencePainter({required this.events});

  final List<SecurityEvent> events;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = GenesisColors.border.withValues(alpha: .18)
      ..strokeWidth = .5;

    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    const buckets = 8;
    final counts = List<int>.filled(buckets, 0);
    final now = DateTime.now();

    for (final event in events) {
      final ageMinutes = now.difference(event.occurredAt.toLocal()).inMinutes;

      if (ageMinutes < 0 || ageMinutes > 60) {
        continue;
      }

      var bucket = buckets - 1 - ((ageMinutes / 60) * buckets).floor();

      bucket = bucket.clamp(0, buckets - 1);
      counts[bucket]++;
    }

    final maxValue = [...counts, 1].reduce(math.max);

    final slot = size.width / buckets;
    final barWidth = slot * .44;

    for (var i = 0; i < buckets; i++) {
      final ratio = counts[i] / maxValue;
      final h = ratio * (size.height - 12);
      final x = i * slot + (slot - barWidth) / 2;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          size.height - h - 4,
          barWidth,
          h,
        ),
        const Radius.circular(2),
      );

      canvas.drawRRect(
        rect,
        Paint()
          ..color = GenesisColors.cyan.withValues(alpha: .22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      canvas.drawRRect(
        rect,
        Paint()..color = GenesisColors.cyan,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LiveEvidencePainter oldDelegate) => true;
}

class _OperationConsole extends StatelessWidget {
  const _OperationConsole();
  @override
  Widget build(BuildContext context) {
    const actions = [
      ('CONTAIN THREAT', Icons.gps_fixed_rounded, GenesisColors.danger),
      ('ISOLATE ENDPOINT', Icons.lock_outline_rounded, GenesisColors.warning),
      ('DEPLOY COUNTERMEASURE', Icons.shield_outlined, GenesisColors.cyan),
      ('RUN INVESTIGATION', Icons.search_rounded, Color(0xFF9BC9E5)),
      ('GENERATE REPORT', Icons.article_outlined, Color(0xFFB4CAD8)),
      (
        'ALL SYSTEMS SECURE',
        Icons.verified_user_rounded,
        GenesisColors.emerald
      ),
    ];
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: const BoxDecoration(
          color: Color(0xFF050B1A),
          border: Border(top: BorderSide(color: GenesisColors.border))),
      child: Row(children: [
        const Icon(Icons.chevron_right_rounded, color: GenesisColors.emerald),
        const Text('OPERATION CONSOLE',
            style: TextStyle(color: GenesisColors.cyan, fontSize: 9)),
        const SizedBox(width: 22),
        for (final a in actions) ...[
          Expanded(
              child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${a.$1}: control selected. Live response service must be connected before execution.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: Icon(a.$2, size: 15),
                  label: Text(a.$1,
                      style: const TextStyle(
                          fontSize: 8, fontWeight: FontWeight.w800)),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: a.$3,
                      side: BorderSide(color: a.$3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4))))),
          const SizedBox(width: 8),
        ],
        const Text('UNITED NATIONS OF IC-391',
            style: TextStyle(color: GenesisColors.muted, fontSize: 7)),
      ]),
    );
  }
}

class _SectionScreen extends StatelessWidget {
  const _SectionScreen({
    required this.index,
    required this.pulse,
  });

  final int index;
  final Animation<double> pulse;

  static const sections = <(String, String, IconData)>[
    ('COMMAND CENTER', 'CHILD PROTECTION OPERATIONS', Icons.home_rounded),
    (
      'MISSING CHILDREN',
      'MISSING PERSON RECORDS AND CASE SEARCH',
      Icons.child_care_rounded
    ),
    (
      'ACTIVE CASES',
      'INVESTIGATION CASE MANAGEMENT',
      Icons.folder_open_rounded
    ),
    (
      'CHILD PROTECTION',
      'SAFEGUARDING AND RISK ASSESSMENT',
      Icons.shield_rounded
    ),
    ('OSINT INVESTIGATIONS', 'PUBLIC SOURCE RESEARCH', Icons.search_rounded),
    ('MAPS & LOCATION ANALYSIS', 'CASE GEOGRAPHIC ANALYSIS', Icons.map_rounded),
    (
      'CAMERAS & SURVEILLANCE',
      'AUTHORIZED CAMERA REVIEW',
      Icons.videocam_rounded
    ),
    (
      'IMAGE & VIDEO ANALYSIS',
      'MEDIA EXAMINATION AND COMPARISON',
      Icons.image_search_rounded
    ),
    (
      'DIGITAL FORENSICS',
      'AUTHORIZED DIGITAL EVIDENCE REVIEW',
      Icons.fingerprint_rounded
    ),
    ('EVIDENCE VAULT', 'CASE FILES AND CHAIN OF CUSTODY', Icons.lock_rounded),
    (
      'ALERTS & BULLETINS',
      'VERIFIED MISSING CHILD BULLETINS',
      Icons.warning_rounded
    ),
    (
      'RECOVERY OPERATIONS',
      'SEARCH COORDINATION AND REUNIFICATION',
      Icons.handshake_rounded
    ),
    (
      'PARTNER / AGENCY SOURCES',
      'AUTHORIZED INFORMATION SOURCES',
      Icons.groups_rounded
    ),
    (
      'REPORTS',
      'CASE REPORTS AND INVESTIGATION SUMMARIES',
      Icons.description_rounded
    ),
    (
      'SYSTEM ADMIN',
      'ACCESS CONTROL AND SYSTEM SETTINGS',
      Icons.settings_rounded
    ),
    (
      'AGENT X',
      'AI COMMAND AND INTELLIGENCE INTERFACE',
      Icons.smart_toy_rounded
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (index == 2) return const ActiveCasesScreen();

    final safeIndex = index.clamp(0, sections.length - 1);
    final section = sections[safeIndex];

    return Container(
      color: GenesisColors.voidBlack,
      padding: const EdgeInsets.all(12),
      child: _ConnectedModule(
        title: section.$1,
        subtitle: section.$2,
        icon: section.$3,
        child: _buildSectionContent(safeIndex),
      ),
    );
  }

  Widget _buildSectionContent(int index) {
    if (index == 3) {
      return const ChildProtectionScreen();
    }

    if (index == 1) {
      return const MissingChildrenScreen();
    }

    if (index == 2) {
      return const ActiveCasesScreen();
    }

    if (index == 6) {
      return const CameraVaultPanel();
    }

    if (index == 9) {
      return const _EvidencePanel();
    }

    if (index == 15) {
      return AgentXScreen();
    }

    final section = sections[index];

    return IC391ModuleWorkspace(
      key: ValueKey('ic391_module_$index'),
      title: section.$1,
      subtitle: section.$2,
    );
  }
}

class _ConnectedModule extends StatelessWidget {
  const _ConnectedModule({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.2,
          colors: [
            Color(0xFF071D42),
            GenesisColors.voidBlack,
            Color(0xFF13092F),
          ],
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          SizedBox(
            height: 66,
            child: _Panel(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 9,
              ),
              child: _PanelHeader(
                icon: icon,
                title: title,
                subtitle: subtitle,
                trailing: const _MiniPill(
                  'CONNECTED',
                  GenesisColors.emerald,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _MapZeroState extends StatelessWidget {
  const _MapZeroState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xE607142B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GenesisColors.warning),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sensors_off_rounded,
            color: GenesisColors.warning,
            size: 28,
          ),
          SizedBox(height: 7),
          Text(
            'AWAITING VERIFIED TELEMETRY',
            style: TextStyle(
              color: GenesisColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 3),
          Text(
            '0 ACTIVE THREATS - NO DATA SOURCE CONNECTED',
            style: TextStyle(
              color: GenesisColors.muted,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.all(10),
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final accent = borderColor;
    final primaryGlow = accent ?? GenesisColors.cyan;
    final secondaryGlow =
        accent == null ? GenesisColors.purpleBright : GenesisColors.gold;

    return Container(
      decoration: BoxDecoration(
        gradient: accent == null
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8AFAFF),
                  Color(0xFF21D8FF),
                  Color(0xFF397BFF),
                  Color(0xFFB340FF),
                  Color(0xFFFF3FA4),
                ],
                stops: [0, .18, .43, .76, 1],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: 1),
                  GenesisColors.gold,
                  const Color(0xFFFFE38A),
                  accent.withValues(alpha: .90),
                ],
                stops: const [0, .34, .58, 1],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryGlow.withValues(alpha: .42),
            blurRadius: 24,
            spreadRadius: .4,
          ),
          BoxShadow(
            color: secondaryGlow.withValues(alpha: .32),
            blurRadius: 36,
            spreadRadius: .8,
          ),
          BoxShadow(
            color: GenesisColors.pink.withValues(alpha: .16),
            blurRadius: 48,
            spreadRadius: .2,
          ),
          const BoxShadow(
            color: Color(0x99000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.45),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF103A7A),
                Color(0xFF0A285A),
                Color(0xFF071B40),
                Color(0xFF0B1637),
                Color(0xFF24104D),
              ],
              stops: [0, .24, .50, .72, 1],
            ),
            borderRadius: BorderRadius.circular(18.55),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: .045),
                blurRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.55),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                Positioned(
                  left: -42,
                  top: -48,
                  width: 190,
                  height: 150,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          GenesisColors.cyan.withValues(alpha: .30),
                          GenesisColors.cyan.withValues(alpha: .10),
                          Colors.transparent,
                        ],
                        stops: const [0, .46, 1],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -52,
                  bottom: -55,
                  width: 205,
                  height: 170,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          secondaryGlow.withValues(alpha: .25),
                          GenesisColors.purple.withValues(alpha: .12),
                          Colors.transparent,
                        ],
                        stops: const [0, .48, 1],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: -45,
                  width: 125,
                  height: 90,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: .075),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 2.3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: accent == null
                            ? [
                                Colors.white.withValues(alpha: .70),
                                GenesisColors.cyan,
                                GenesisColors.purpleBright,
                                GenesisColors.pink.withValues(alpha: .85),
                                Colors.transparent,
                              ]
                            : [
                                Colors.white.withValues(alpha: .62),
                                GenesisColors.gold,
                                accent,
                                accent.withValues(alpha: .45),
                                Colors.transparent,
                              ],
                        stops: const [0, .18, .50, .80, 1],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 1.1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          primaryGlow.withValues(alpha: .78),
                          primaryGlow.withValues(alpha: .22),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 22,
                  bottom: 8,
                  width: 1.05,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          secondaryGlow.withValues(alpha: .24),
                          secondaryGlow.withValues(alpha: .70),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 22,
                  right: 22,
                  bottom: 0,
                  height: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          primaryGlow.withValues(alpha: .28),
                          secondaryGlow.withValues(alpha: .38),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: padding,
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader(
      {required this.icon,
      required this.title,
      required this.subtitle,
      this.trailing,
      this.iconColor = GenesisColors.cyan});
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Color iconColor;
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 7),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              maxLines: 1,
              style: const TextStyle(
                  color: GenesisColors.text,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .5)),
          Text(subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: GenesisColors.muted,
                  fontSize: 6.5,
                  letterSpacing: .5)),
        ])),
        if (trailing != null) trailing!,
      ]);
}

class _MiniPill extends StatelessWidget {
  const _MiniPill(this.label, this.color);
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          border: Border.all(color: color.withValues(alpha: .5)),
          borderRadius: BorderRadius.circular(3)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 6.5, fontWeight: FontWeight.w800)));
}

class _CheckLine extends StatelessWidget {
  const _CheckLine(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(children: [
        const Icon(Icons.check_rounded, color: GenesisColors.emerald, size: 12),
        const SizedBox(width: 6),
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: GenesisColors.muted, fontSize: 6.5))),
        Text(value,
            style: const TextStyle(
                color: GenesisColors.emerald,
                fontSize: 6.5,
                fontWeight: FontWeight.w700)),
      ]));
}

class _DotValue extends StatelessWidget {
  const _DotValue(this.value, this.label, this.color);
  final String value;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Icon(Icons.circle, color: color, size: 7),
        const SizedBox(width: 5),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 7, fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(color: GenesisColors.muted, fontSize: 5.5))
        ])
      ]));
}

class _ValueLine extends StatelessWidget {
  const _ValueLine(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        SizedBox(
            width: 62,
            child: Text(label,
                style:
                    const TextStyle(color: GenesisColors.muted, fontSize: 6))),
        Text(value,
            style: const TextStyle(
                color: GenesisColors.text,
                fontSize: 7,
                fontWeight: FontWeight.w800))
      ]));
}

class _PercentRing extends StatelessWidget {
  const _PercentRing();
  @override
  Widget build(BuildContext context) => Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: GenesisColors.emerald, width: 5),
          boxShadow: [
            BoxShadow(
                color: GenesisColors.emerald.withValues(alpha: .25),
                blurRadius: 12)
          ]),
      child: const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('100%',
            style: TextStyle(
                color: GenesisColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w900)),
        Text('READY', style: TextStyle(color: GenesisColors.muted, fontSize: 6))
      ])));
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => SizedBox(
      height: 42,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (final h in [22.0, 36.0, 18.0, 31.0, 25.0, 39.0, 21.0, 34.0])
          Expanded(
              child: Container(
                  height: h,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  color: color.withValues(alpha: .75)))
      ]));
}

class _WorldThreatPainter extends CustomPainter {
  const _WorldThreatPainter(this.phase);
  final double phase;
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = GenesisColors.border.withValues(alpha: .18)
      ..strokeWidth = .5;
    for (double x = 0; x < size.width; x += 24)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    for (double y = 0; y < size.height; y += 24)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);

    final land = Paint()
      ..color = const Color(0xFF16415B)
      ..style = PaintingStyle.fill;
    final coast = Paint()
      ..color = GenesisColors.cyan.withValues(alpha: .55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final continents = <List<double>>[
      [.08, .25, .16, .15, .27, .18, .33, .29, .27, .39, .19, .42, .12, .35],
      [.27, .45, .35, .50, .33, .68, .28, .84, .24, .66],
      [.42, .25, .49, .18, .58, .23, .55, .34, .48, .38],
      [.49, .40, .58, .41, .62, .66, .54, .78, .47, .57],
      [.57, .24, .72, .18, .88, .28, .91, .43, .78, .49, .68, .39],
      [.78, .62, .90, .65, .92, .77, .82, .80, .75, .70],
    ];
    for (final raw in continents) {
      final path = Path()..moveTo(raw[0] * size.width, raw[1] * size.height);
      for (var i = 2; i < raw.length; i += 2)
        path.lineTo(raw[i] * size.width, raw[i + 1] * size.height);
      path.close();
      canvas.drawPath(path, land);
      canvas.drawPath(path, coast);
    }
    final nodes = [
      const Offset(.17, .32),
      const Offset(.28, .50),
      const Offset(.48, .29),
      const Offset(.56, .48),
      const Offset(.72, .30),
      const Offset(.84, .39),
      const Offset(.85, .70),
      const Offset(.33, .67)
    ];
    final colors = [
      GenesisColors.danger,
      GenesisColors.warning,
      GenesisColors.danger,
      GenesisColors.cyan,
      GenesisColors.danger,
      GenesisColors.warning,
      GenesisColors.danger,
      GenesisColors.emerald
    ];
    for (var i = 0; i < nodes.length; i++) {
      final p = Offset(nodes[i].dx * size.width, nodes[i].dy * size.height);
      final glow = Paint()
        ..color = colors[i].withValues(alpha: .16)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
          p, 10 + 5 * math.sin((phase + i / 7) * math.pi * 2).abs(), glow);
      canvas.drawCircle(p, 3.5, Paint()..color = colors[i]);
    }
    final routePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (var i = 0; i < nodes.length - 1; i++) {
      final a = Offset(nodes[i].dx * size.width, nodes[i].dy * size.height);
      final b =
          Offset(nodes[i + 1].dx * size.width, nodes[i + 1].dy * size.height);
      routePaint.color = colors[i].withValues(alpha: .8);
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..quadraticBezierTo((a.dx + b.dx) / 2,
            math.min(a.dy, b.dy) - size.height * .22, b.dx, b.dy);
      canvas.drawPath(path, routePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WorldThreatPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _TrafficPainter extends CustomPainter {
  const _TrafficPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = GenesisColors.border.withValues(alpha: .25)
      ..strokeWidth = .5;
    for (double y = 8; y < size.height; y += 14)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    void wave(Color color, double frequency, double shift) {
      final p = Path();
      for (double x = 0; x <= size.width; x += 4) {
        final y = size.height * .52 +
            math.sin(x / frequency + shift) * size.height * .22 +
            math.sin(x / 11) * 5;
        if (x == 0)
          p.moveTo(x, y);
        else
          p.lineTo(x, y);
      }
      canvas.drawPath(
          p,
          Paint()
            ..color = color
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke);
    }

    wave(GenesisColors.cyan, 22, 0);
    wave(GenesisColors.danger, 29, 1.8);
    wave(const Color(0xFF3988FF), 17, 3.4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
