import 'package:flutter/material.dart';

import '../../../../shared/design/broker_colors.dart';

class DecisionFooter extends StatelessWidget {
  const DecisionFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Text(
        'BrokerOS karar desteği sunar; kesin kazanç vaat etmez. '
        'İşlem büyüklüğü ve zarar sınırı her zaman kullanıcıya aittir.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: BrokerColors.textSoft,
          fontSize: 10,
          height: 1.4,
        ),
      ),
    );
  }
}
