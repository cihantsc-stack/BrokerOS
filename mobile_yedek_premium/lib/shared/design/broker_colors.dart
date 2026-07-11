import 'package:flutter/material.dart';

class BrokerColors {
  BrokerColors._();

  // Background
  static const background = Color(0xFF05070B);
  static const backgroundSoft = Color(0xFF0A1018);

  // Cards
  static const card = Color(0xFF111821);
  static const cardSoft = Color(0xFF171F2B);
  static const cardDeep = Color(0xFF0D141E);

  // Borders
  static const border = Color(0xFF2B3748);
  static const borderSoft = Color(0xFF202C3D);

  // CROC Green (Premium)
  static const primary = Color(0xFF2FE07A);
  static const primaryDark = Color(0xFF1BAA5A);
  static const primarySoft = Color(0xFF143926);

  // Accent Colors
  static const green = Color(0xFF2FE07A);
  static const orange = Color(0xFFFFB547);
  static const red = Color(0xFFFF5D73);
  static const blue = Color(0xFF4CA8FF);
  static const purple = Color(0xFFA783FF);

  // Text
  static const textMain = Color(0xFFF8FAFC);
  static const textSoft = Color(0xFFAAB6C7);
  static const textMuted = Color(0xFF6E7B8F);

  static const buy = green;
  static const sell = red;
  static const risk = orange;
  static const info = blue;

  // Premium Glow
  static const glow = Color(0x332FE07A);

  // Premium Gradients
  static const crocGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF39F28A),
      Color(0xFF1BAA5A),
    ],
  );

  static const darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF182231),
      Color(0xFF0A1018),
    ],
  );

  static const premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF202B3A),
      Color(0xFF101821),
    ],
  );
}