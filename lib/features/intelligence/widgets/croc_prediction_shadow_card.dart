import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../core/prediction/engines/croc_prediction_engine.dart';
import '../../../core/prediction/models/croc_prediction.dart';
import '../../../core/prediction/models/prediction_horizon.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class CrocPredictionShadowCard extends StatelessWidget {
  final StockAnalysis stock;

  const CrocPredictionShadowCard({
    super.key,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    final predictions =
        const CrocPredictionEngine().analyze(stock);

    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: BrokerColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: BrokerColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CROC Prediction Engine V1',
                      style: TextStyle(
                        color: BrokerColors.textMain,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '1 / 5 / 20 işlem günü için gölge mod tahmini',
                      style: TextStyle(
                        color: BrokerColors.textSoft,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _ShadowBadge(),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              if (width < 760) {
                return Column(
                  children: [
                    for (var i = 0; i < predictions.length; i++) ...[
                      _PredictionTile(prediction: predictions[i]),
                      if (i != predictions.length - 1)
                        const SizedBox(height: 10),
                    ],
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < predictions.length; i++) ...[
                    Expanded(
                      child: _PredictionTile(
                        prediction: predictions[i],
                      ),
                    ),
                    if (i != predictions.length - 1)
                      const SizedBox(width: 10),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          _QualityStrip(predictions: predictions),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BrokerColors.background.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: BrokerColors.textSoft.withValues(alpha: 0.12),
              ),
            ),
            child: const Text(
              'Not: Buradaki yüzde “model olasılığı”dır. Henüz gerçek geçmiş sonuçlarla '
              'kalibre edilmiş başarı olasılığı değildir. Tahminler gölge modda izlenecektir.',
              style: TextStyle(
                color: BrokerColors.textSoft,
                fontSize: 10.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PredictionTile extends StatelessWidget {
  final CrocPrediction prediction;

  const _PredictionTile({
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    final tone = _toneFor(prediction);
    final horizon = prediction.horizon;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: tone.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                horizon.label,
                style: const TextStyle(
                  color: BrokerColors.textMain,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                '%${prediction.modelProbability}',
                style: TextStyle(
                  color: tone,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            prediction.direction,
            style: TextStyle(
              color: tone,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _MetricRow(
            label: 'Güven',
            value: '%${prediction.confidence}',
          ),
          const SizedBox(height: 7),
          _MetricRow(
            label: 'Risk',
            value: '%${prediction.riskScore}',
          ),
          const SizedBox(height: 7),
          _MetricRow(
            label: 'Rejim',
            value: prediction.regime,
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: prediction.modelProbability / 100,
              minHeight: 7,
              backgroundColor:
                  BrokerColors.textSoft.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation<Color>(tone),
            ),
          ),
        ],
      ),
    );
  }

  static Color _toneFor(CrocPrediction prediction) {
    final text = prediction.direction.toUpperCase();

    if (text.contains('GÜÇLÜ POZİTİF') ||
        text == 'POZİTİF') {
      return BrokerColors.green;
    }

    if (text.contains('NEGATİF') || text == 'ZAYIF') {
      return BrokerColors.red;
    }

    return BrokerColors.orange;
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetricRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: BrokerColors.textSoft,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _QualityStrip extends StatelessWidget {
  final List<CrocPrediction> predictions;

  const _QualityStrip({
    required this.predictions,
  });

  @override
  Widget build(BuildContext context) {
    if (predictions.isEmpty) {
      return const SizedBox.shrink();
    }

    final sample = predictions.first;
    final active = sample.snapshot.activeSignalCount;
    final positives = sample.positiveFactors;
    final negatives = sample.negativeFactors;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MiniChip(text: 'Aktif veri $active/6'),
        if (positives.isNotEmpty)
          _MiniChip(text: positives.first),
        if (negatives.isNotEmpty)
          _MiniChip(text: negatives.first, warning: true),
      ],
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String text;
  final bool warning;

  const _MiniChip({
    required this.text,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final tone =
        warning ? BrokerColors.orange : BrokerColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: tone.withValues(alpha: 0.20),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: tone,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ShadowBadge extends StatelessWidget {
  const _ShadowBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: BrokerColors.orange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: BrokerColors.orange.withValues(alpha: 0.28),
        ),
      ),
      child: const Text(
        'GÖLGE MOD',
        style: TextStyle(
          color: BrokerColors.orange,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
