import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    const seed = Color(0xFFD32F2F);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: seed,
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: const CardTheme(
        color: Color(0xFF1E1E1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1E1E1E),
        border: OutlineInputBorder(),
      ),
    );
  }

  static ThemeData get lightTheme {
    const seed = Color(0xFFD32F2F);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: seed,
    );
  }
}
