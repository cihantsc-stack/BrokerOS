import 'package:flutter/material.dart';

import '../../../core/repository/mock_market_repository.dart';
import '../../../core/services/broker_vision_service.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_badge.dart';
import '../../../shared/widgets/broker_card.dart';

class MorningBriefCard extends StatelessWidget {
  const MorningBriefCard({super.key});

  @override
  Widget build(BuildContext context) {
    final data = MockMarketRepository().getTodaySnapshot();
    final vision = BrokerVisionService.generate(data);

    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrokerBadge(text: 'Broker Vision'),
          const SizedBox(height: 14),
          const Text(
            'Günaydın Cihan.',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            vision,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}