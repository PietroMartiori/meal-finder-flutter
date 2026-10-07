import 'package:flutter/material.dart';

/// Cores e estilos compartilhados pela interface do MealFinder.
class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFFFF6B3D);
  static const Color ink = Color(0xFF202124);
  static const Color mutedText = Color(0xFF858990);
  static const Color background = Color(0xFFF8F9FB);
  static const Color softSurface = Color(0xFFFFEEE8);
  static const Color line = Color(0xFFE8EAED);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: ink,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        color: ink,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.1,
      ),
      titleLarge: TextStyle(
        color: ink,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      titleMedium: TextStyle(
        color: ink,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: mutedText, fontSize: 16, height: 1.35),
      bodyMedium: TextStyle(color: mutedText, fontSize: 14),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ink,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE9E2DE)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE9E2DE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
    ),
  );
}
