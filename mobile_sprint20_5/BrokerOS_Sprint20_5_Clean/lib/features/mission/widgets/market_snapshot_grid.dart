import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';
import 'mission_components.dart';

class MarketSnapshotGrid extends StatelessWidget {
  const MarketSnapshotGrid();

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MissionCardTitle(
            icon: Icons.monitor_heart_rounded,
            title: 'Piyasa Panoraması',
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: MissionMarketBox(
                  title: 'BIST100',
                  value: '+1.82%',
                  color: BrokerColors.green,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: MissionMarketBox(
                  title: 'DOLAR/TL',
                  value: '-0.15%',
                  color: BrokerColors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: MissionMarketBox(
                  title: 'GRAM ALTIN',
                  value: '+0.65%',
                  color: BrokerColors.green,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: MissionMarketBox(
                  title: 'VİOP 30',
                  value: '+1.24%',
                  color: BrokerColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
