import 'package:flutter/material.dart';

import '../../../core/dna/decision_dna.dart';
import '../../../core/dna/dna_factor.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class BrokerDecisionDnaCard extends StatelessWidget {
  final DecisionDna dna;

  const BrokerDecisionDnaCard({super.key, required this.dna});

  Color get _decisionColor {
    if (dna.decision.contains('AL')) return BrokerColors.green;
    if (dna.decision.contains('SAT')) return BrokerColors.red;
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
              Icon(Icons.hub_rounded, color: BrokerColors.primary, size: 29),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Broker Decision DNA',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${dna.profile} profil. Ana karar geni: ${dna.dominantGene}.',
            style: const TextStyle(color: BrokerColors.textSoft, height: 1.45),
          ),
          const SizedBox(height: 18),
          for (int index = 0; index < dna.factors.length; index++) ...[
            _DnaFactorRow(factor: dna.factors[index]),
            if (index != dna.factors.length - 1) const SizedBox(height: 14),
          ],
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _decisionColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _decisionColor.withValues(alpha: 0.22)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOPLAM KARAR DNA GÜCÜ',
                        style: TextStyle(
                          color: BrokerColors.textSoft,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.7,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dna.decision,
                        style: TextStyle(
                          color: _decisionColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dna.profile,
                        style: const TextStyle(
                          color: BrokerColors.textMain,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${dna.totalPower}/100',
                  style: const TextStyle(
                    color: BrokerColors.primary,
                    fontSize: 27,
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

class _DnaFactorRow extends StatelessWidget {
  final DnaFactor factor;

  const _DnaFactorRow({required this.factor});

  Color get _color {
    if (factor.share >= 22) return BrokerColors.green;
    if (factor.share >= 14) return BrokerColors.primary;
    return BrokerColors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                factor.name,
                style: const TextStyle(
                  color: BrokerColors.textMain,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '%${factor.share}',
              style: TextStyle(color: _color, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: factor.share / 100,
            minHeight: 11,
            backgroundColor: BrokerColors.borderSoft,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${factor.interpretation} Ham skor ${factor.rawScore}, katkı ${factor.contribution}.',
          style: const TextStyle(
            color: BrokerColors.textSoft,
            fontSize: 12,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
