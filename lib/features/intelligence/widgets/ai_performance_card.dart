import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/performance/decision_accuracy_engine.dart';
import '../../../core/performance/decision_outcome.dart';
import '../../../core/performance/decision_statistics.dart';
import '../../../core/timeline/decision_timeline_engine.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiPerformanceCard extends StatefulWidget {
  final String symbol;
  final DecisionTimelineEngine timelineEngine;
  final DecisionAccuracyEngine performanceEngine;

  const AiPerformanceCard({
    super.key,
    required this.symbol,
    required this.timelineEngine,
    required this.performanceEngine,
  });

  @override
  State<AiPerformanceCard> createState() => _AiPerformanceCardState();
}

class _AiPerformanceCardState extends State<AiPerformanceCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = widget.timelineEngine.historyOf(widget.symbol, limit: 50);
    final statistics = widget.performanceEngine.evaluate(history);

    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: BrokerColors.primary,
                size: 29,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'CROC AI Performansı',
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
          const Text(
            'Kararlar, bir sonraki fiyat kaydıyla otomatik olarak doğrulanır.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.4),
          ),
          const SizedBox(height: 16),
          _Summary(statistics: statistics),
          const SizedBox(height: 16),
          if (!statistics.hasEvaluatedDecision)
            const _WaitingPanel()
          else
            _AccuracyBar(value: statistics.accuracyPercent),
          if (statistics.records.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Son karar sonuçları',
              style: TextStyle(
                color: BrokerColors.textMain,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            for (final record in statistics.records.take(4)) ...[
              _OutcomeRow(record: record),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final DecisionStatistics statistics;

  const _Summary({required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _Metric(label: 'Toplam karar', value: '${statistics.totalDecisions}'),
        _Metric(label: 'Doğru', value: '${statistics.successfulDecisions}'),
        _Metric(label: 'Yanlış', value: '${statistics.unsuccessfulDecisions}'),
        _Metric(
          label: 'Başarı',
          value: statistics.hasEvaluatedDecision
              ? '%${statistics.accuracyPercent.toStringAsFixed(1)}'
              : '—',
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BrokerColors.primary.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccuracyBar extends StatelessWidget {
  final double value;

  const _AccuracyBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Doğruluk oranı',
                style: TextStyle(
                  color: BrokerColors.textMain,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '%${value.toStringAsFixed(1)}',
              style: const TextStyle(
                color: BrokerColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: BrokerColors.textSoft.withValues(alpha: 0.10),
            valueColor: const AlwaysStoppedAnimation<Color>(
              BrokerColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _WaitingPanel extends StatelessWidget {
  const _WaitingPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: BrokerColors.textSoft.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.hourglass_top_rounded, color: BrokerColors.textSoft),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Başarı ölçümü için en az iki farklı fiyat kaydı gerekiyor.',
              style: TextStyle(
                color: BrokerColors.textSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutcomeRow extends StatelessWidget {
  final DecisionOutcomeRecord record;

  const _OutcomeRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final isSuccess = record.outcome == DecisionOutcome.successful;
    final isPending = record.outcome == DecisionOutcome.pending;
    final tone = isPending
        ? BrokerColors.textSoft
        : isSuccess
        ? BrokerColors.primary
        : BrokerColors.red;

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: tone.withValues(alpha: 0.13)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              record.signalLabel,
              style: const TextStyle(
                color: BrokerColors.textMain,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            isPending
                ? 'Takipte'
                : '${record.returnPercent >= 0 ? '+' : ''}'
                      '${record.returnPercent.toStringAsFixed(2)}%',
            style: TextStyle(color: tone, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 10),
          Text(
            record.outcome.label,
            style: TextStyle(
              color: tone,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
