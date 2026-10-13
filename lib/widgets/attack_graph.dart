import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/genesis_theme.dart';
import '../data/demo_data.dart';
import '../models/security_models.dart';

class AttackGraph extends StatelessWidget {
  const AttackGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _NetworkPainter(),
              ),
            ),
            Positioned(
              left: 12,
              top: constraints.maxHeight * .33,
              child: const _ThreatNode(),
            ),
            Positioned(
              left: constraints.maxWidth * .25,
              top: constraints.maxHeight * .39,
              child: const _AssetNode(
                asset: ProtectedAsset(
                  name: 'EDGE GATEWAY',
                  address: '7/7 CONTROLS',
                  type: 'PATH CONTAINED',
                  icon: Icons.grid_view_rounded,
                ),
                emphasize: true,
              ),
            ),
            ..._assetPositions(constraints.maxWidth, constraints.maxHeight),
            Positioned(
              right: 12,
              top: 10,
              child: Container(
                width: math.min(210, constraints.maxWidth * .28),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: GenesisColors.danger.withValues(alpha: .08),
                  border: Border.all(
                      color: GenesisColors.danger.withValues(alpha: .7)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PATH CONTAINED',
                      style: TextStyle(
                        color: GenesisColors.text,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .8,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ATTACK BLOCKED • LATERAL MOVEMENT PREVENTED • NO DATA EXFILTRATION',
                      style: TextStyle(
                          color: GenesisColors.muted, fontSize: 9, height: 1.4),
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

  List<Widget> _assetPositions(double width, double height) {
    final usable = width * .53;
    final left = width * .43;
    final assets = DemoData.assets.take(5).toList();
    final positions = <Offset>[
      Offset(left, height * .10),
      Offset(left, height * .48),
      Offset(left + usable * .34, height * .24),
      Offset(left + usable * .49, height * .52),
      Offset(left + usable * .10, height * .72),
    ];
    return List.generate(assets.length, (index) {
      final p = positions[index];
      return Positioned(
        left: p.dx,
        top: p.dy,
        child: _AssetNode(asset: assets[index]),
      );
    });
  }
}

class _ThreatNode extends StatelessWidget {
  const _ThreatNode();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GenesisColors.danger.withValues(alpha: .15),
              border: Border.all(color: GenesisColors.danger, width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0x66FF4D5A), blurRadius: 18)
              ],
            ),
            child: const Icon(Icons.person_off_outlined,
                color: GenesisColors.danger),
          ),
          const SizedBox(height: 7),
          const Text(
            'SUSPICIOUS NODE',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: GenesisColors.text,
                fontSize: 9,
                fontWeight: FontWeight.w800),
          ),
          const Text(
            'ACCESS DENIED',
            style: TextStyle(color: GenesisColors.danger, fontSize: 8),
          ),
        ],
      ),
    );
  }
}

class _AssetNode extends StatelessWidget {
  const _AssetNode({required this.asset, this.emphasize = false});

  final ProtectedAsset asset;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final color = emphasize ? GenesisColors.cyan : GenesisColors.emerald;
    return SizedBox(
      width: 118,
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: .13),
              border: Border.all(color: color, width: 1.6),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: .35), blurRadius: 12)
              ],
            ),
            child: Icon(asset.icon, color: color, size: 21),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  maxLines: 2,
                  style: const TextStyle(
                    color: GenesisColors.text,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  asset.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontSize: 7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = GenesisColors.border.withValues(alpha: .18)
      ..strokeWidth = .6;
    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final gateway = Offset(size.width * .31, size.height * .48);
    final threat = Offset(68, size.height * .45);
    final attackPaint = Paint()
      ..color = GenesisColors.danger
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    _dashedLine(canvas, threat, gateway, attackPaint);

    final securePaint = Paint()
      ..color = GenesisColors.cyan.withValues(alpha: .75)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final targets = [
      Offset(size.width * .48, size.height * .18),
      Offset(size.width * .48, size.height * .56),
      Offset(size.width * .70, size.height * .33),
      Offset(size.width * .82, size.height * .62),
      Offset(size.width * .60, size.height * .78),
    ];
    for (final target in targets) {
      final path = Path()
        ..moveTo(gateway.dx, gateway.dy)
        ..cubicTo(
          gateway.dx + (target.dx - gateway.dx) * .45,
          gateway.dy,
          gateway.dx + (target.dx - gateway.dx) * .55,
          target.dy,
          target.dx,
          target.dy,
        );
      canvas.drawPath(path, securePaint);
    }
  }

  void _dashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final distance = (end - start).distance;
    final direction = (end - start) / distance;
    const dash = 8.0;
    const gap = 6.0;
    var traveled = 0.0;
    while (traveled < distance) {
      final segmentEnd = math.min(traveled + dash, distance);
      canvas.drawLine(
          start + direction * traveled, start + direction * segmentEnd, paint);
      traveled += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
