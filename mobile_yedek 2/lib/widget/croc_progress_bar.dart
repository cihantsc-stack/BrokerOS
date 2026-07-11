import 'package:flutter/material.dart';
import '../core/theme/croc_colors.dart';

class CrocProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;

  const CrocProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 9,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(0.0, 1.0);
    final barColor = color ?? CrocColors.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: safeValue,
        minHeight: height,
        backgroundColor: CrocColors.borderSoft,
        valueColor: AlwaysStoppedAnimation<Color>(barColor),
      ),
    );
  }
}