import 'package:flutter/material.dart';
import '../design/broker_colors.dart';

class BrokerCard extends StatelessWidget {
  final Widget child;

  const BrokerCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BrokerColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: BrokerColors.border),
      ),
      child: child,
    );
  }
}
