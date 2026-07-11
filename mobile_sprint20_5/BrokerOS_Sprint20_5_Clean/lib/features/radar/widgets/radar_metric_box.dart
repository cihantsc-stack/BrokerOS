import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';

class RadarMetricBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const RadarMetricBox({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft.withOpacity(.75),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
