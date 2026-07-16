import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiScoreCard extends StatelessWidget {
  const AiScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Row(
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: Stack(
              alignment: Alignment.center,
              children: const [
                CircularProgressIndicator(
                  value: 0.91,
                  strokeWidth: 10,
                  color: BrokerColors.primary,
                  backgroundColor: BrokerColors.border,
                ),
                Text(
                  '91',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: BrokerColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Piyasa Skoru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                SizedBox(height: 8),
                Text(
                  'Güçlü pozitif görünüm. Bugün seçici ama fırsat odaklı olmak daha doğru.',
                  style: TextStyle(color: BrokerColors.textSoft, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
