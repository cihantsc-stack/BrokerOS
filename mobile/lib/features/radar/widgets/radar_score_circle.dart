import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';

class RadarScoreCircle extends StatelessWidget {
  final int score;

  const RadarScoreCircle({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      height: 66,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 5,
            backgroundColor: BrokerColors.borderSoft,
            valueColor: const AlwaysStoppedAnimation<Color>(
              BrokerColors.primary,
            ),
          ),
          Text(
            '$score',
            style: const TextStyle(
              color: BrokerColors.primary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
