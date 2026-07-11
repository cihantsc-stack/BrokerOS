import 'package:flutter/material.dart';
import '../core/theme/croc_colors.dart';

enum CrocButtonType {
  primary,
  secondary,
  ghost,
}

class CrocButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final CrocButtonType type;

  const CrocButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.type = CrocButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    final bool primary = type == CrocButtonType.primary;
    final bool ghost = type == CrocButtonType.ghost;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              gradient: primary ? CrocColors.crocGradient : null,
              color: primary
                  ? null
                  : ghost
                      ? Colors.transparent
                      : CrocColors.cardSoft,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: primary
                    ? CrocColors.primary.withOpacity(.35)
                    : CrocColors.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: primary ? Colors.black : CrocColors.textPrimary,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: primary ? Colors.black : CrocColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}