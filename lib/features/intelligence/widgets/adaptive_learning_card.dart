import 'package:flutter/material.dart';

import '../../../core/learning/models/adaptive_learning_profile.dart';
import '../../../core/learning/models/learning_module_weight.dart';
import '../../../core/learning/models/learning_prediction_record.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AdaptiveLearningCard extends StatelessWidget {
  final AdaptiveLearningProfile profile;

  const AdaptiveLearningCard({super.key, required this.profile});

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
                Icons.auto_graph_rounded,
                color: BrokerColors.primary,
                size: 30,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'PRO PACK 1F • Öğrenen AI',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            '${profile.symbol} için geçmiş karar kalıpları ve '
            'modül başarıları değerlendirildi.',
            style: const TextStyle(color: BrokerColors.textSoft, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  title: 'Tahmin',
                  value: '${profile.totalPredictions}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Metric(
                  title: 'Başarı',
                  value: '%${profile.successRate}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Metric(
                  title: 'Benzer Yapı',
                  value: '%${profile.similarPatternSuccessRate}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoLine(
            icon: Icons.workspace_premium_rounded,
            title: 'En güçlü modül',
            value: profile.strongestModule,
          ),
          _InfoLine(
            icon: Icons.warning_amber_rounded,
            title: 'Dikkat edilen modül',
            value: profile.weakestModule,
          ),
          _InfoLine(
            icon: Icons.schedule_rounded,
            title: 'En uygun süre',
            value: profile.bestHoldingPeriod,
          ),
          const SizedBox(height: 14),
          const Text(
            'Öğrenilmiş Modül Ağırlıkları',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          ...profile.moduleWeights.map(
            (LearningModuleWeight item) => _WeightRow(weight: item),
          ),
          const SizedBox(height: 14),
          const Text(
            'AI Ne Öğrendi?',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          ...profile.learnedInsights.map(
            (String insight) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✓ ',
                    style: TextStyle(
                      color: BrokerColors.green,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      insight,
                      style: const TextStyle(
                        color: BrokerColors.textSoft,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (profile.recentRecords.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Son Kayıt',
              style: TextStyle(
                color: BrokerColors.textMain,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            ...profile.recentRecords.map(
              (LearningPredictionRecord record) => _RecordRow(record: record),
            ),
          ],
          const SizedBox(height: 9),
          const Text(
            'Bu aşamada öğrenme geçmişi demo/simülasyon '
            'verisidir. Canlı sonuç doğrulaması veri bağlantısı '
            'sonrasında kalıcı depolamaya alınacaktır.',
            style: TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightRow extends StatelessWidget {
  final LearningModuleWeight weight;

  const _WeightRow({required this.weight});

  @override
  Widget build(BuildContext context) {
    final bool increased = weight.change >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              weight.module,
              style: const TextStyle(
                color: BrokerColors.textMain,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '%${(weight.adaptiveWeight * 100).toStringAsFixed(1)}',
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: (increased ? BrokerColors.green : BrokerColors.red)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              weight.changeLabel,
              style: TextStyle(
                color: increased ? BrokerColors.green : BrokerColors.red,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String title;
  final String value;

  const _Metric({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BrokerColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoLine({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: BrokerColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: BrokerColors.textSoft),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final LearningPredictionRecord record;

  const _RecordRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final Color tone = record.successful
        ? BrokerColors.green
        : BrokerColors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${record.decision} • ${record.holdingDays} gün',
              style: const TextStyle(
                color: BrokerColors.textMain,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '${record.simulatedReturn >= 0 ? '+' : ''}'
            '%${record.simulatedReturn.toStringAsFixed(1)}',
            style: TextStyle(color: tone, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
