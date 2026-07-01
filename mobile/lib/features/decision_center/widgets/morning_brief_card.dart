import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_badge.dart';
import '../../../shared/widgets/broker_card.dart';

class MorningBriefCard extends StatelessWidget {
  const MorningBriefCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrokerBadge(text: 'Sabah Brifingi'),
          SizedBox(height: 14),
          Text('Günaydın Cihan.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(
            'Bugün piyasayı senin için analiz ettim. Genel görünüm pozitif, risk seviyesi orta.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.45),
          ),
        ],
      ),
    );
  }
}
