import 'package:flutter/material.dart';
import 'croc_colors.dart';

class CrocTheme {
  CrocTheme._();

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CrocColors.background,
      fontFamily: 'Inter',
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: CrocColors.primary,
        secondary: CrocColors.info,
        surface: CrocColors.card,
        error: CrocColors.danger,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: CrocColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w900,
        ),
        headlineMedium: TextStyle(
          color: CrocColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
        titleLarge: TextStyle(
          color: CrocColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        bodyLarge: TextStyle(
          color: CrocColors.textPrimary,
          fontSize: 16,
          height: 1.35,
        ),
        bodyMedium: TextStyle(
          color: CrocColors.textSecondary,
          fontSize: 14,
          height: 1.35,
        ),
      ),
    );
  }
}