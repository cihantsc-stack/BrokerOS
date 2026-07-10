import 'package:flutter/material.dart';
import '../shared/design/broker_colors.dart';

class BrokerTheme {
  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: BrokerColors.background,
    primaryColor: BrokerColors.primary,
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.dark(
      primary: BrokerColors.primary,
      secondary: BrokerColors.blue,
      surface: BrokerColors.card,
      error: BrokerColors.red,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: BrokerColors.textMain,
        fontSize: 34,
        fontWeight: FontWeight.w900,
      ),
      headlineMedium: TextStyle(
        color: BrokerColors.textMain,
        fontSize: 26,
        fontWeight: FontWeight.w900,
      ),
      titleLarge: TextStyle(
        color: BrokerColors.textMain,
        fontSize: 21,
        fontWeight: FontWeight.w900,
      ),
      bodyLarge: TextStyle(
        color: BrokerColors.textMain,
        fontSize: 16,
        height: 1.35,
      ),
      bodyMedium: TextStyle(
        color: BrokerColors.textSoft,
        fontSize: 14,
        height: 1.35,
      ),
    ),
  );
}
