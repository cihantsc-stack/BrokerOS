import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class SmartMoneyCard extends StatelessWidget {
  const SmartMoneyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Akıllı Para', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(
            'Son 60 dakikada güçlü para girişi izleniyor. Bankacılık ve savunma ön planda.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.4),
          ),
        ],
      ),
    );
  }
}
