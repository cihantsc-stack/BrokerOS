import 'package:flutter/material.dart';
import '../core/theme/croc_colors.dart';

class CrocSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const CrocSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: CrocColors.primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: CrocColors.primary.withOpacity(.18)),
            ),
            child: Icon(icon, color: CrocColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    color: CrocColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  )),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!,
                    style: const TextStyle(
                      color: CrocColors.textSecondary,
                      fontSize: 13,
                      height: 1.25,
                    )),
              ],
            ],
          ),
        ),
      ],
    );
  }
}