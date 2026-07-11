import 'package:flutter/material.dart';

import '../../shared/design/broker_colors.dart';
import '../../shared/widgets/broker_card.dart';
import '../../shared/widgets/broker_page.dart';
import '../../shared/widgets/page_title.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitle('Portföy'),
          SizedBox(height: 18),
          BrokerCard(
            child: Text(
              'Portföy dağılımı, kâr/zarar, risk skoru ve AI yorumları burada olacak.',
              style: TextStyle(color: BrokerColors.textSoft, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
