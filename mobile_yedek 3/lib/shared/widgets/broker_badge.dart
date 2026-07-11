import 'package:flutter/material.dart';
import '../design/broker_colors.dart';

class BrokerBadge extends StatelessWidget {
  final String text;

  const BrokerBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: BrokerColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: BrokerColors.primary.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: BrokerColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
