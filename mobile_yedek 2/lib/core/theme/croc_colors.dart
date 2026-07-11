import 'package:flutter/material.dart';

class CrocColors {
  CrocColors._();

  // Ana zemin
  static const Color background = Color(0xFF070B12);
  static const Color backgroundSoft = Color(0xFF0B1220);

  // Kartlar
  static const Color card = Color(0xFF111827);
  static const Color cardSoft = Color(0xFF172033);
  static const Color cardGlass = Color(0xCC121B2D);

  // CROC marka rengi
  static const Color primary = Color(0xFF35D07F);
  static const Color primaryDark = Color(0xFF168C52);
  static const Color primarySoft = Color(0xFF1F6F49);

  // Durum renkleri
  static const Color success = Color(0xFF35D07F);
  static const Color danger = Color(0xFFFF4D5E);
  static const Color warning = Color(0xFFFFB84D);
  static const Color info = Color(0xFF4DA3FF);
  static const Color ai = Color(0xFF9B7CFF);

  // Yazılar
  static const Color textPrimary = Color(0xFFF3F7FB);
  static const Color textSecondary = Color(0xFFA8B3C7);
  static const Color textMuted = Color(0xFF6F7D95);

  // Çizgiler
  static const Color border = Color(0xFF263247);
  static const Color borderSoft = Color(0xFF1C2638);

  // Finans anlamları
  static const Color buy = success;
  static const Color sell = danger;
  static const Color risk = warning;
  static const Color neutral = textSecondary;

  // Gölge
  static Color shadow = Colors.black.withOpacity(0.35);

  // Gradientler
  static const LinearGradient crocGradient = LinearGradient(
    colors: [
      Color(0xFF35D07F),
      Color(0xFF168C52),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [
      Color(0xFF101827),
      Color(0xFF070B12),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient glassGradient = LinearGradient(
    colors: [
      Colors.white.withOpacity(0.06),
      Colors.white.withOpacity(0.02),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}