import 'package:flutter/material.dart';
import '../core/theme/croc_colors.dart';

enum CrocBadgeType {
  buy,
  sell,
  risk,
  info,
  ai,
  neutral,
}

class CrocBadge extends StatelessWidget {
  final String text;
  final CrocBadgeType type;
  final IconData? icon;

  const CrocBadge({
    super.key,
    required this.text,
    this.type = CrocBadgeType.neutral,
    this.icon,
  });

  Color get _color {
    switch (type) {
      case CrocBadgeType.buy:
        return CrocColors.buy;
      case CrocBadgeType.sell:
        return CrocColors.sell;
      case CrocBadgeType.risk:
        return CrocColors.risk;
      case CrocBadgeType.info:
        return CrocColors.info;
      case CrocBadgeType.ai:
        return CrocColors.ai;
      case CrocBadgeType.neutral:
        return CrocColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _color.withOpacity(.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: _color.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: _color),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: _color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: .2,
            ),
          ),
        ],
      ),
    );
  }
}