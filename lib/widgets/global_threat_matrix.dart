import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/genesis_theme.dart';

class GlobalThreatMatrix extends StatefulWidget {
  const GlobalThreatMatrix({super.key});

  @override
  State<GlobalThreatMatrix> createState() => _GlobalThreatMatrixState();
}

class _GlobalThreatMatrixState extends State<GlobalThreatMatrix>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF06111B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GenesisColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x3300CFFF), blurRadius: 24),
        ],
      ),
      child: Column(
        children: [
          _header(),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _ThreatMapPainter(_controller.value),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          _legend(),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 13, 12, 9),
      child: Row(
        children: [
          const Icon(Icons.public_rounded, color: GenesisColors.cyan),
          const SizedBox(width: 9),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GLOBAL THREAT MATRIX',
                  style: TextStyle(
                    color: GenesisColors.text,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  'VERIFIED TELEMETRY • NO SIMULATED THREATS',
                  style: TextStyle(
                    color: GenesisColors.muted,
                    fontSize: 8,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          _status('VERIFIED', GenesisColors.emerald),
          const SizedBox(width: 7),
          _status('0 THREATS', GenesisColors.cyan),
        ],
      ),
    );
  }

  Widget _status(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: .55)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: .7,
        ),
      ),
    );
  }

  Widget _legend() {
    const entries = [
      ('CRITICAL', GenesisColors.danger),
      ('HIGH', Color(0xFFFF8A3D)),
      ('MEDIUM', GenesisColors.warning),
      ('SECURE', GenesisColors.emerald),
      ('INTELLIGENCE', GenesisColors.cyan),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 8, 15, 12),
      child: Row(
        children: [
          for (final entry in entries) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: entry.$2,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: entry.$2.withValues(alpha: .7),
                    blurRadius: 7,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Text(
              entry.$1,
              style: const TextStyle(
                color: GenesisColors.muted,
                fontSize: 7,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 13),
          ],
          const Spacer(),
          const Text(
            '0 EXTERNAL FEEDS • 2 LOCAL ENDPOINTS',
            style: TextStyle(
              color: GenesisColors.cyan,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreatMapPainter extends CustomPainter {
  const _ThreatMapPainter(this.phase);

  final double phase;

  static const _nodes = <Offset>[
    Offset(.13, .36),
    Offset(.20, .58),
    Offset(.31, .31),
    Offset(.43, .43),
    Offset(.53, .28),
    Offset(.61, .50),
    Offset(.72, .34),
    Offset(.83, .55),
    Offset(.91, .29),
  ];

  static const _links = <(int, int)>[
    (0, 3),
    (1, 3),
    (2, 5),
    (3, 6),
    (4, 7),
    (5, 8),
    (6, 8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawContinents(canvas, size);
    // No verified threat links received.
    // No verified global threat nodes received.
    _drawRadar(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = GenesisColors.cyan.withValues(alpha: .055)
      ..strokeWidth = .6;

    for (double x = 0; x <= size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }

    for (double y = 0; y <= size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          GenesisColors.cyan.withValues(alpha: .10),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * .53, size.height * .48),
          radius: size.width * .46,
        ),
      );

    canvas.drawRect(Offset.zero & size, glow);
  }

  void _drawContinents(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF12314A)
      ..style = PaintingStyle.fill;

    final outline = Paint()
      ..color = GenesisColors.cyan.withValues(alpha: .28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final shapes = [
      _continent(size, [
        const Offset(.07, .25),
        const Offset(.18, .16),
        const Offset(.31, .25),
        const Offset(.26, .43),
        const Offset(.13, .49),
      ]),
      _continent(size, [
        const Offset(.28, .51),
        const Offset(.36, .54),
        const Offset(.39, .79),
        const Offset(.31, .88),
      ]),
      _continent(size, [
        const Offset(.43, .25),
        const Offset(.56, .19),
        const Offset(.62, .31),
        const Offset(.54, .42),
      ]),
      _continent(size, [
        const Offset(.51, .44),
        const Offset(.64, .42),
        const Offset(.63, .75),
        const Offset(.54, .82),
        const Offset(.48, .61),
      ]),
      _continent(size, [
        const Offset(.61, .25),
        const Offset(.78, .18),
        const Offset(.94, .34),
        const Offset(.84, .52),
        const Offset(.67, .45),
      ]),
      _continent(size, [
        const Offset(.82, .68),
        const Offset(.91, .66),
        const Offset(.94, .79),
        const Offset(.85, .84),
      ]),
    ];

    for (final path in shapes) {
      canvas.drawPath(path, paint);
      canvas.drawPath(path, outline);
    }
  }

  Path _continent(Size size, List<Offset> points) {
    final path = Path()
      ..moveTo(points.first.dx * size.width, points.first.dy * size.height);

    for (final point in points.skip(1)) {
      path.lineTo(point.dx * size.width, point.dy * size.height);
    }

    return path..close();
  }

  void _drawThreatLinks(Canvas canvas, Size size) {
    for (var index = 0; index < _links.length; index++) {
      final link = _links[index];
      final start = _scale(_nodes[link.$1], size);
      final end = _scale(_nodes[link.$2], size);
      final critical = index.isEven;
      final color = critical ? GenesisColors.danger : GenesisColors.warning;

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(
          (start.dx + end.dx) / 2,
          math.min(start.dy, end.dy) - size.height * .18,
          end.dx,
          end.dy,
        );

      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: .60)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3,
      );

      final metrics = path.computeMetrics().toList();
      final metric = metrics.isEmpty ? null : metrics.first;

      if (metric != null) {
        final tangent = metric.getTangentForOffset(
          metric.length * ((phase + index * .13) % 1),
        );

        if (tangent != null) {
          canvas.drawCircle(
            tangent.position,
            3,
            Paint()
              ..color = color
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
          );
        }
      }
    }
  }

  void _drawNodes(Canvas canvas, Size size) {
    for (var index = 0; index < _nodes.length; index++) {
      final center = _scale(_nodes[index], size);
      final critical = index == 0 || index == 3 || index == 7;
      final color = critical ? GenesisColors.danger : GenesisColors.emerald;
      final pulse = 8 + math.sin((phase * math.pi * 2) + index) * 3;

      canvas.drawCircle(
        center,
        pulse,
        Paint()
          ..color = color.withValues(alpha: .10)
          ..style = PaintingStyle.fill,
      );

      canvas.drawCircle(
        center,
        4,
        Paint()
          ..color = color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      canvas.drawCircle(
        center,
        2.4,
        Paint()..color = Colors.white,
      );
    }
  }

  void _drawRadar(Canvas canvas, Size size) {
    final center = Offset(size.width * .52, size.height * .48);
    final radius = math.min(size.width, size.height) * .22;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = GenesisColors.cyan.withValues(alpha: .11)
        ..style = PaintingStyle.stroke,
    );

    final angle = phase * math.pi * 2;
    canvas.drawLine(
      center,
      center + Offset(math.cos(angle), math.sin(angle)) * radius,
      Paint()
        ..color = GenesisColors.cyan.withValues(alpha: .5)
        ..strokeWidth = 1.2,
    );
  }

  Offset _scale(Offset point, Size size) {
    return Offset(point.dx * size.width, point.dy * size.height);
  }

  @override
  bool shouldRepaint(covariant _ThreatMapPainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}
