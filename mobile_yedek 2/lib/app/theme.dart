import 'package:flutter/material.dart';
import '../shared/design/broker_colors.dart';

class BrokerTheme {
  static ThemeData dark = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: BrokerColors.background,
    primaryColor: BrokerColors.primary,
  );
}
