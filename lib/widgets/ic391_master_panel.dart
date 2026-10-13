import 'package:flutter/material.dart';
import '../core/genesis_theme.dart';

class IC391MasterPanel extends StatelessWidget {
  const IC391MasterPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(10),
    this.borderColor,
    this.color,
    this.margin,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final accent = borderColor;
    final primaryGlow = accent ?? GenesisColors.cyan;
    final secondaryGlow =
        accent == null ? GenesisColors.purpleBright : GenesisColors.gold;

    return Container(
      margin: margin,
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
