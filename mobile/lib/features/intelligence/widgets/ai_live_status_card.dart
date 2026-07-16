import 'package:flutter/material.dart';

import '../../../core/models/ai_decision.dart';
import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiLiveStatusCard extends StatelessWidget {
  final StockAnalysis stock;
  final AiDecision decision;

  const AiLiveStatusCard({
    super.key,
    required this.stock,
    required this.decision,
  });

  Color get _statusColor {
    if (decision.decision.contains('AL')) return BrokerColors.green;
    if (decision.decision.contains('SAT')) return BrokerColors.red;
    return BrokerColors.orange;
  }

  String get _statusText {
    if (stock.smartMoneyScore >= 85 && stock.momentumScore >= 80) {
      return 'Kurumsal para ve momentum aynı yönde.';
    }
    if (stock.smartMoneyScore < 65) {
      return 'Smart Money teyidi bekleniyor.';
    }
    return 'CROC AI piyasayı izliyor ve kararı koruyor.';
  }

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _statusColor.withValues(alpha: 0.45),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'CROC AI Canlı Durum',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: _statusColor.withValues(alpha: 0.24),
                  ),
                ),
                child: Text(
                  'CANLI',
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusMetric(
                title: 'MOD',
                value: decision.decision,
                color: _statusColor,
              ),
              _StatusMetric(
                title: 'GÜVEN',
                value: '%${decision.confidence}',
                color: BrokerColors.primary,
              ),
              _StatusMetric(
                title: 'RİSK',
                value: decision.risk.toUpperCase(),
                color: decision.risk.toLowerCase() == 'orta'
                    ? BrokerColors.orange
                    : BrokerColors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _statusText,
            style: const TextStyle(
              color: BrokerColors.textMain,
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Son hesaplama: az önce',
            style: TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMetric extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatusMetric({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 105),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
