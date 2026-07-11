import 'package:flutter/material.dart';
import '../core/theme/croc_colors.dart';

class CrocMetricTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? color;

  const CrocMetricTile({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? CrocColors.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CrocColors.cardSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CrocColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: c, size: 20),
            const SizedBox(height: 10),
          ],
          Text(
            title,
            style: const TextStyle(
              color: CrocColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: c,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}