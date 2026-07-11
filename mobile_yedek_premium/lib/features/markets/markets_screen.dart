import 'package:flutter/material.dart';

import '../../shared/design/broker_colors.dart';
import '../../shared/widgets/broker_card.dart';
import '../../shared/widgets/broker_page.dart';
import '../../shared/widgets/page_title.dart';

class MarketsScreen extends StatelessWidget {
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitle('Piyasalar'),
          SizedBox(height: 18),
          BrokerCard(
            child: Text(
              'Hisse, fon, altın, kripto ve diğer varlık sınıfları burada olacak.',
              style: TextStyle(color: BrokerColors.textSoft, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
