import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class NewsImpactCard extends StatelessWidget {
  const NewsImpactCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Haber Etkisi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(
            'Günün haber akışı genel olarak pozitif. Öğleden sonra makro veri kaynaklı volatilite artabilir.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.4),
          ),
        ],
      ),
    );
  }
}
