import 'package:flutter/material.dart';

import '../../../core/models/ai_decision.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiConfidenceCard extends StatelessWidget {
  final AiDecision decision;

  const AiConfidenceCard({super.key, required this.decision});

  Color get _decisionColor {
    if (decision.decision.contains('AL')) return BrokerColors.green;
    if (decision.decision.contains('SAT')) return BrokerColors.red;
    return BrokerColors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.psychology_alt_rounded,
                color: BrokerColors.primary,
                size: 28,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CROC AI Karar Özeti',
                      style: TextStyle(
                        color: BrokerColors.textMain,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Karar, güven, risk ve güçlü-zayıf faktörler.',
                      style: TextStyle(color: BrokerColors.textSoft),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Badge(
                text: decision.decision,
                color: _decisionColor,
                icon: Icons.bolt_rounded,
              ),
              _Badge(
                text: 'GÜVEN %${decision.confidence}',
                color: BrokerColors.primary,
                icon: Icons.verified_rounded,
              ),
              _Badge(
                text: 'RİSK ${decision.risk.toUpperCase()}',
                color: decision.risk.toLowerCase() == 'orta'
                    ? BrokerColors.orange
                    : BrokerColors.green,
                icon: Icons.shield_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: decision.confidence / 100,
              minHeight: 12,
              backgroundColor: BrokerColors.borderSoft,
              valueColor: AlwaysStoppedAnimation<Color>(_decisionColor),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'Birleşik skor ${decision.pusuScore}/100',
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          _Fact(
            title: 'En Güçlü Faktör',
            value: decision.strongestFactor,
            icon: Icons.trending_up_rounded,
            color: BrokerColors.green,
          ),
          const SizedBox(height: 10),
          _Fact(
            title: 'En Zayıf Faktör',
            value: decision.weakestFactor,
            icon: Icons.warning_amber_rounded,
            color: BrokerColors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            decision.explanation,
            style: const TextStyle(
              color: BrokerColors.textMain,
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const _Badge({required this.text, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _Fact({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Veri bekleniyor' : value,
                  style: const TextStyle(
                    color: BrokerColors.textMain,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
