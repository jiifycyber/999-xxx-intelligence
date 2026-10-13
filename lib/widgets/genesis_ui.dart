import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/genesis_theme.dart';

class GenesisPanel extends StatelessWidget {
  const GenesisPanel({
    required this.child,
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsets padding;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: GenesisColors.panel.withValues(alpha: .96),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? GenesisColors.border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3,
                    height: 32,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: GenesisColors.gold,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(color: Color(0x66E2B84F), blurRadius: 8),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title!,
                            style: Theme.of(context).textTheme.titleLarge),
                        if (subtitle != null)
                          Text(
                            subtitle!.toUpperCase(),
                            style: const TextStyle(
                              color: GenesisColors.muted,
                              fontSize: 10,
                              letterSpacing: 1.4,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 14),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    required this.label,
    super.key,
    this.color = GenesisColors.emerald,
    this.icon = Icons.check_circle_rounded,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: .55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
            ),
          ),
        ],
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    super.key,
    this.color = GenesisColors.emerald,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GenesisPanel(
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: GenesisColors.border),
              color: GenesisColors.panelRaised,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: GenesisColors.muted,
                    fontSize: 10,
                    letterSpacing: .8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
                Text(detail,
                    style: const TextStyle(
                        color: GenesisColors.muted, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RiskGauge extends StatelessWidget {
  const RiskGauge({required this.value, super.key});

  final int value;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 138,
      child: CustomPaint(
        painter: _GaugePainter(progress: value / 100),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$value',
                style: const TextStyle(
                  color: GenesisColors.text,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'FORTIFIED',
                style: TextStyle(
                  color: GenesisColors.emerald,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const start = -math.pi / 2;
    final background = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..color = GenesisColors.border;
    final foreground = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 9
      ..shader = const SweepGradient(
        colors: [GenesisColors.cyan, GenesisColors.emerald],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, background);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      math.pi * 2 * progress,
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class SectionPlaceholder extends StatelessWidget {
  const SectionPlaceholder({
    required this.title,
    required this.description,
    required this.icon,
    required this.capabilities,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<String> capabilities;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: GenesisColors.gold.withValues(alpha: .12),
                  border: Border.all(color: GenesisColors.goldSoft),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: GenesisColors.gold, size: 34),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 5),
                    Text(description),
                  ],
                ),
              ),
              const StatusPill(label: 'GENESIS CONTROLLED'),
            ],
          ),
          const SizedBox(height: 28),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 330,
                mainAxisExtent: 128,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: capabilities.length,
              itemBuilder: (context, index) => GenesisPanel(
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_outlined,
                        color: GenesisColors.emerald),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        capabilities[index],
                        style: const TextStyle(
                          color: GenesisColors.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
