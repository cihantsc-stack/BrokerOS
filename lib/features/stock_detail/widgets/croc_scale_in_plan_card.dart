import 'package:flutter/material.dart';

import '../../../core/analysis/croc_technical_analysis.dart';
import '../../../core/trade/croc_scale_in_engine.dart';

class CrocScaleInPlanCard extends StatelessWidget {
  const CrocScaleInPlanCard({
    super.key,
    required this.currentPrice,
    required this.analysis,
  });

  final double currentPrice;
  final CrocTechnicalAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final plan = CrocScaleInEngine.build(
      currentPrice: currentPrice,
      analysis: analysis,
    );

    if (plan.steps.isEmpty) return const SizedBox.shrink();

    final first = plan.steps.first;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1916),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF294039)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        iconColor: const Color(0xFF70F4AD),
        collapsedIconColor: const Color(0xFF71877D),
        title: const Text(
          'CROC KADEMELİ ALIM PLANI',
          style: TextStyle(
            color: Color(0xFFB8C8C2),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: .5,
          ),
        ),
        subtitle: Text(
          '${first.label} • ${first.low.toStringAsFixed(2)}–'
          '${first.high.toStringAsFixed(2)} TL • '
          '%${first.allocationPercent}  |  ${plan.status}',
          style: const TextStyle(
            color: Color(0xFF70F4AD),
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        children: [
          for (final step in plan.steps)
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: Text(
                      step.label,
                      style: const TextStyle(
                        color: Color(0xFFC5D2CD),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${step.low.toStringAsFixed(2)}–'
                      '${step.high.toStringAsFixed(2)} TL',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '%${step.allocationPercent}',
                    style: const TextStyle(
                      color: Color(0xFF70F4AD),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'PLAN STOPU ${plan.stop.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFFFF8A92),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                'ANA HEDEF ${plan.target.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFFFFC857),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Risk yükseldikçe sermaye daha alt kademelere kayar. '
            'Stop altındaki seviyelerde ek alım yapılmaz.',
            style: TextStyle(
              color: Color(0xFF7F938C),
              fontSize: 9.5,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
