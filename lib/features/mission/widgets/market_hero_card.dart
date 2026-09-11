import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';

class MarketHeroCard extends StatelessWidget {
  const MarketHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: BrokerColors.cardDeep,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: BrokerColors.primary.withValues(alpha: 0.58)),
        boxShadow: [
          BoxShadow(
            color: BrokerColors.primary.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TitleRow(),
          SizedBox(height: 18),
          Text(
            'SEÇİCİ ALIM MODU',
            style: TextStyle(
              color: BrokerColors.primary,
              fontSize: 35,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          SizedBox(height: 14),
          Text(
            'Piyasa genelinde para akışı pozitif ancak yükseliş '
            'bütün sektörlere eşit dağılmıyor. Hacimli kırılımlar '
            'tercih edilmeli, plansız ve stop seviyesiz işlem açılmamalı.',
            style: TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          SizedBox(height: 19),
          Row(
            children: [
              Expanded(
                child: _DecisionMetric(
                  label: 'Güven',
                  value: '%88',
                  tone: BrokerColors.green,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _DecisionMetric(
                  label: 'Risk',
                  value: 'Orta',
                  tone: BrokerColors.orange,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _DecisionMetric(
                  label: 'Piyasa Modu',
                  value: 'Seçici',
                  tone: BrokerColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: BrokerColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: BrokerColors.primary.withValues(alpha: 0.26),
            ),
          ),
          child: const Icon(
            Icons.psychology_alt_rounded,
            color: BrokerColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Bugünkü Piyasa Kararı',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _DecisionMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;

  const _DecisionMetric({
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        color: BrokerColors.background.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: BrokerColors.border.withValues(alpha: 0.70)),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: tone,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
