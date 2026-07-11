import 'package:flutter/material.dart';
import '../core/theme/croc_colors.dart';

class CrocChip extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  const CrocChip({
    super.key,
    required this.text,
    this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? CrocColors.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: chipColor.withOpacity(.10),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: chipColor.withOpacity(.20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: chipColor),
              const SizedBox(width: 7),
            ],
            Text(
              text,
              style: TextStyle(
                color: chipColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}