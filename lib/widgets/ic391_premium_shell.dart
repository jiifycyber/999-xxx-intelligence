import 'package:flutter/material.dart';

class IC391PremiumShell extends StatelessWidget {
  const IC391PremiumShell({
    super.key,
    required this.child,
    this.radius = 20,
  });

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8AFAFF),
            Color(0xFF21D8FF),
            Color(0xFF397BFF),
            Color(0xFFB340FF),
            Color(0xFFFF3FA4),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x6621D8FF),
            blurRadius: 24,
          ),
          BoxShadow(
            color: Color(0x44B340FF),
            blurRadius: 36,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius - 2),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF071D42),
              Color(0xFF13092F),
              Color(0xFF050B1A),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}

class IC391PremiumTheme extends StatelessWidget {
  const IC391PremiumTheme({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);

    const cyan = Color(0xFF25EDFF);
    const gold = Color(0xFFE2B84F);
    const midnight = Color(0xFF050B1A);
    const panel = Color(0xFF071D42);
    const purple = Color(0xFFA23CFF);

    return Theme(
      data: base.copyWith(
        scaffoldBackgroundColor: midnight,
        canvasColor: midnight,
        cardColor: panel,
        dialogTheme: DialogThemeData(
          backgroundColor: midnight,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: cyan, width: 1.5),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: midnight,
          modalBackgroundColor: midnight,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: midnight,
          labelStyle: const TextStyle(color: cyan),
          hintStyle: const TextStyle(color: Color(0xFF9DAAC6)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: purple),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: cyan, width: 2),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: panel,
            foregroundColor: cyan,
            side: const BorderSide(color: cyan),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: cyan,
            side: const BorderSide(color: purple),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: gold,
          ),
        ),
      ),
      child: child,
    );
  }
}
