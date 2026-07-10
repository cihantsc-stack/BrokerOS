import 'package:flutter/material.dart';

import '../../../shared/widgets/broker_card.dart';
import 'mission_components.dart';

class RiskDisciplineCard extends StatelessWidget {
  const RiskDisciplineCard();

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MissionCardTitle(
            icon: Icons.shield_rounded,
            title: 'Bugün Bunları Yapma',
          ),
          SizedBox(height: 14),
          MissionWarningLine('Stop seviyesi olmadan işlem açma.'),
          MissionWarningLine('Direnç bölgesinde hacimsiz kırılıma güvenme.'),
          MissionWarningLine('Volatilite artarken kaldıraçlı işlemde agresif olma.'),
        ],
      ),
    );
  }
}
