import 'package:flutter/material.dart';
import '../design/broker_colors.dart';

class BrokerCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool glow;
  final VoidCallback? onTap;

  const BrokerCard({
    super.key,
    required this.child,
    this.padding,
    this.glow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: BrokerColors.premiumGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: glow
              ? BrokerColors.primary.withOpacity(.42)
              : BrokerColors.border.withOpacity(.88),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.42),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          if (glow)
            BoxShadow(
              color: BrokerColors.primary.withOpacity(.16),
              blurRadius: 30,
              spreadRadius: 1,
            ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: card,
      ),
    );
  }
}