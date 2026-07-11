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
      padding: padding ?? const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: BrokerColors.darkGradient,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: glow ? BrokerColors.primary.withOpacity(.35) : BrokerColors.border,
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.38),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          if (glow)
            BoxShadow(
              color: BrokerColors.primary.withOpacity(.13),
              blurRadius: 34,
              spreadRadius: 1,
            ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;

    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: card,
    );
  }
}
