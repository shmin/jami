import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        colorSchemeSeed: const Color(0xFF4F6CF7),
        brightness: Brightness.light,
        useMaterial3: true,
      );

  static ThemeData get dark => ThemeData(
        colorSchemeSeed: const Color(0xFF4F6CF7),
        brightness: Brightness.dark,
        useMaterial3: true,
      );
}
