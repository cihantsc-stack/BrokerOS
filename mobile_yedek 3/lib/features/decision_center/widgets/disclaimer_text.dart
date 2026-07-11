import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';

class DisclaimerText extends StatelessWidget {
  const DisclaimerText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'YTD: Broker OS yatırım tavsiyesi vermez. Veriyi anlamlandırarak karar desteği sağlar.',
      style: TextStyle(color: BrokerColors.textMuted, fontSize: 12),
    );
  }
}
