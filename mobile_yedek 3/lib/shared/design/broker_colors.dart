import 'package:flutter/material.dart';

class BrokerColors {
  BrokerColors._();

  static const background = Color(0xFF060A11);
  static const backgroundSoft = Color(0xFF0B111D);

  static const card = Color(0xFF101827);
  static const cardSoft = Color(0xFF172033);
  static const cardDeep = Color(0xFF0B1220);

  static const border = Color(0xFF243149);
  static const borderSoft = Color(0xFF1B263A);

  static const primary = Color(0xFF35D07F);
  static const primaryDark = Color(0xFF168C52);
  static const primarySoft = Color(0xFF163D2A);

  static const green = Color(0xFF35D07F);
  static const orange = Color(0xFFFFB84D);
  static const red = Color(0xFFFF4D5E);
  static const blue = Color(0xFF4DA3FF);
  static const purple = Color(0xFF9B7CFF);

  static const textMain = Color(0xFFF3F7FB);
  static const textSoft = Color(0xFFA8B3C7);
  static const textMuted = Color(0xFF6F7D95);

  static const buy = green;
  static const sell = red;
  static const risk = orange;
  static const info = blue;

  static const crocGradient = LinearGradient(
    colors: [Color(0xFF35D07F), Color(0xFF168C52)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkGradient = LinearGradient(
    colors: [Color(0xFF121C2E), Color(0xFF0B111D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
