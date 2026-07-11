import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';

class RadarHeader extends StatelessWidget {
  const RadarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Radar',
          style: TextStyle(
            color: BrokerColors.textMain,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'CROC AI bugün filtreyi geçen en güçlü fırsatları taradı.',
          style: TextStyle(
            color: BrokerColors.textSoft,
            fontSize: 15,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
