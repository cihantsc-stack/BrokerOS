import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';

class AiBriefCard extends StatelessWidget {
  const AiBriefCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: BrokerColors.cardDeep,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: BrokerColors.border.withValues(alpha: 0.82)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _BriefIcon(),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'CROC AI Sabah Yorumu',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 17),
          Text(
            'Güne pozitif bir para akışıyla başlanıyor. Bankacılık, '
            'savunma ve ulaştırma sektörlerinde hareketlilik artarken '
            'hacim teyidi gelmeyen yükselişlerde acele edilmemeli. '
            'Ana strateji, desteklere yakın kademeli işlem ve net stop planıdır.',
            style: TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _BriefChip(label: 'Para Akışı Pozitif', tone: BrokerColors.green),
              _BriefChip(label: 'Risk Orta', tone: BrokerColors.orange),
              _BriefChip(label: 'Seçici Ol', tone: BrokerColors.primary),
            ],
          ),
        ],
      ),
    );
  }
}

class _BriefIcon extends StatelessWidget {
  const _BriefIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: BrokerColors.primary.withValues(alpha: 0.25)),
      ),
      child: const Icon(Icons.smart_toy_rounded, color: BrokerColors.primary),
    );
  }
}

class _BriefChip extends StatelessWidget {
  final String label;
  final Color tone;

  const _BriefChip({required this.label, required this.tone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: tone.withValues(alpha: 0.20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tone,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
