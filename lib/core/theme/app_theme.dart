import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F7FB),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
    ),
    cardColor: Colors.white,
    useMaterial3: true,
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
    ),
    cardColor: const Color(0xFF1E293B),
    useMaterial3: true,
  );
}
