import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';

class RadarInstitutionBox extends StatelessWidget {
  final String first;
  final String second;
  final String third;

  const RadarInstitutionBox({
    super.key,
    required this.first,
    required this.second,
    required this.third,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft.withOpacity(.75),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İlk 3 Kurum',
            style: TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _InstitutionRow(rank: '1', name: first, amount: '+423.6M'),
          _InstitutionRow(rank: '2', name: second, amount: '+198.7M'),
          _InstitutionRow(rank: '3', name: third, amount: '+156.8M'),
        ],
      ),
    );
  }
}

class _InstitutionRow extends StatelessWidget {
  final String rank;
  final String name;
  final String amount;

  const _InstitutionRow({
    required this.rank,
    required this.name,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: BrokerColors.primary.withOpacity(.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: BrokerColors.primary.withOpacity(.22),
              ),
            ),
            child: Text(
              rank,
              style: const TextStyle(
                color: BrokerColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: BrokerColors.textMain,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: BrokerColors.green,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
