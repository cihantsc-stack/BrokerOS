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
    final radius = BorderRadius.circular(24);

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: glow
            ? BrokerColors.heroGradient
            : BrokerColors.premiumGradient,
        borderRadius: radius,
        border: Border.all(
          color: glow
              ? BrokerColors.primary.withOpacity(.48)
              : BrokerColors.border.withOpacity(.86),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: BrokerColors.shadow.withOpacity(.58),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
          if (glow)
            BoxShadow(
              color: BrokerColors.primary.withOpacity(.18),
              blurRadius: 34,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: child,
    );

    // Her BrokerCard artık Material ancestor sağlar. Böylece kartın içindeki
    // InkWell/InkResponse bileşenleri Experience Center dahil hata vermez.
    return Material(
      type: MaterialType.transparency,
      borderRadius: radius,
      child: onTap == null
          ? card
          : InkWell(borderRadius: radius, onTap: onTap, child: card),
    );
  }
}
