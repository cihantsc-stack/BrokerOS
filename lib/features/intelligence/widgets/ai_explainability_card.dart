import 'package:flutter/material.dart';

import '../../../core/explainability/explainability_report.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';
import 'factor_bar.dart';

class AiExplainabilityCard extends StatelessWidget {
  final ExplainabilityReport report;

  const AiExplainabilityCard({super.key, required this.report});

  Color get _decisionColor {
    if (report.finalDecision.contains('AL')) return BrokerColors.green;
    if (report.finalDecision.contains('SAT')) return BrokerColors.red;
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
                size: 29,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'AI Kararı Nasıl Oluştu?',
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
            report.summary,
            style: const TextStyle(color: BrokerColors.textSoft, height: 1.45),
          ),
          const SizedBox(height: 18),
          for (int index = 0; index < report.items.length; index++) ...[
            FactorBar(item: report.items[index]),
            if (index != report.items.length - 1) const SizedBox(height: 17),
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
                        'AÇIKLANABİLİR AI SONUCU',
                        style: TextStyle(
                          color: BrokerColors.textSoft,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.7,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        report.finalDecision,
                        style: TextStyle(
                          color: _decisionColor,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Ana belirleyici: ${report.dominantFactor}',
                        style: const TextStyle(
                          color: BrokerColors.textMain,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '%${report.totalScore}',
                  style: const TextStyle(
                    color: BrokerColors.primary,
                    fontSize: 29,
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
