import 'package:flutter/material.dart';
import '../core/theme/croc_colors.dart';

class CrocCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool glow;

  const CrocCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: CrocColors.darkGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CrocColors.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: CrocColors.shadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          if (glow)
            BoxShadow(
              color: CrocColors.primary.withOpacity(.15),
              blurRadius: 28,
              spreadRadius: 1,
            ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: card,
    );
  }
}