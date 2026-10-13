import 'package:flutter/material.dart';

abstract final class GenesisColors {
  static const voidBlack = Color(0xFF01050F);
  static const midnight = Color(0xFF050B1A);
  static const panel = Color(0xFF071D42);
  static const panelRaised = Color(0xFF092149);
  static const border = Color(0xFF315D8A);
  static const gold = Color(0xFFE2B84F);
  static const goldSoft = Color(0xFF8D7131);
  static const emerald = Color(0xFF22E89A);
  static const cyan = Color(0xFF25EDFF);
  static const purple = Color(0xFFA23CFF);
  static const purpleBright = Color(0xFFD43CFF);
  static const pink = Color(0xFFFF4D87);
  static const glassBlue = Color(0xFF071D42);
  static const glassPurple = Color(0xFF13092F);
  static const warning = Color(0xFFFFC857);
  static const danger = Color(0xFFFF4D5A);
  static const text = Color(0xFFF3F8FC);
  static const caseAccent = Color(0xFF25EDFF);
  static const caseHighlight = Color(0xFFE2B84F);
  static const caseBackground = Color(0xFF050B1A);
  static const muted = Color(0xFF9DAAC6);
}

abstract final class GenesisTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: GenesisColors.gold,
      brightness: Brightness.dark,
      surface: GenesisColors.panel,
      error: GenesisColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: GenesisColors.voidBlack,
      fontFamily: 'Helvetica Neue',
      dividerColor: GenesisColors.border,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: GenesisColors.text,
          fontSize: 30,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
        headlineMedium: TextStyle(
          color: GenesisColors.text,
          fontSize: 21,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
        titleLarge: TextStyle(
          color: GenesisColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: .8,
        ),
        bodyMedium: TextStyle(
          color: GenesisColors.muted,
          fontSize: 13,
          height: 1.35,
        ),
      ),
      cardTheme: const CardThemeData(
        color: GenesisColors.panel,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: GenesisColors.midnight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: GenesisColors.cyan,
            width: 1.5,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: GenesisColors.midnight,
        modalBackgroundColor: GenesisColors.midnight,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GenesisColors.panel,
        hintStyle: const TextStyle(color: GenesisColors.muted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: GenesisColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: GenesisColors.cyan,
            width: 1.8,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GenesisColors.cyan,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: GenesisColors.panelRaised,
          foregroundColor: GenesisColors.text,
          side: const BorderSide(color: GenesisColors.cyan),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: GenesisColors.text,
        iconColor: GenesisColors.cyan,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: GenesisColors.panelRaised,
        contentTextStyle: TextStyle(color: GenesisColors.text),
      ),
    );
  }
}
