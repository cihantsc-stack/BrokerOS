import 'package:flutter/material.dart';

class BrokerColors {
  BrokerColors._();

  static const background = Color(0xFF040609);
  static const backgroundSoft = Color(0xFF080D13);
  static const backgroundLift = Color(0xFF0D141D);

  static const card = Color(0xFF101820);
  static const cardSoft = Color(0xFF151F2B);
  static const cardDeep = Color(0xFF090F16);
  static const glass = Color(0xE6111822);

  static const border = Color(0xFF283646);
  static const borderSoft = Color(0xFF1E2A38);
  static const premiumBorder = Color(0xFF35506B);

  static const primary = Color(0xFF36F08B);
  static const primaryDark = Color(0xFF18A95B);
  static const primarySoft = Color(0xFF123B27);

  static const green = Color(0xFF36F08B);
  static const orange = Color(0xFFFFB74A);
  static const red = Color(0xFFFF5D73);
  static const blue = Color(0xFF58ACFF);
  static const purple = Color(0xFFA78BFA);

  static const textMain = Color(0xFFF8FAFC);
  static const textSoft = Color(0xFFAEB9C9);
  static const textMuted = Color(0xFF6F7B8C);

  static const buy = green;
  static const sell = red;
  static const risk = orange;
  static const info = blue;

  static const shadow = Color(0xB3000000);
  static const glow = Color(0x4036F08B);
  static const premiumGlow = Color(0x5536F08B);

  static const crocGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5AFFA1), Color(0xFF19AA5D)],
  );

  static const darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF15202B), Color(0xFF080D13)],
  );

  static const premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B2733), Color(0xFF0E151E)],
  );

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E2D3C), Color(0xFF0B1119), Color(0xFF0E2017)],
  );
}
