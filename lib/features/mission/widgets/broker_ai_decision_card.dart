import 'package:flutter/material.dart';

import '../../../core/ai/models/broker_ai_decision.dart';
import '../../../core/ai/services/live_broker_ai_service.dart';
import '../../../core/data_foundation/market/twelve_data_market_data_source.dart';
import '../../../shared/design/broker_colors.dart';

class BrokerAiDecisionCard extends StatefulWidget {
  const BrokerAiDecisionCard({super.key});

  @override
  State<BrokerAiDecisionCard> createState() => _BrokerAiDecisionCardState();
}

class _BrokerAiDecisionCardState extends State<BrokerAiDecisionCard> {
  late final LiveBrokerAiService _service;
  late Future<BrokerAiDecision> _future;

  @override
  void initState() {
    super.initState();

    _service = LiveBrokerAiService(dataSource: TwelveDataMarketDataSource());

    _future = _service.buildDecision();
  }

  void _refresh() {
    setState(() {
      _future = _service.buildDecision();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BrokerAiDecision>(
      future: _future,
      builder:
          (BuildContext context, AsyncSnapshot<BrokerAiDecision> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingCard();
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _ErrorCard(onRetry: _refresh);
            }

            return _DecisionView(decision: snapshot.data!, onRefresh: _refresh);
          },
    );
  }
}

class _DecisionView extends StatelessWidget {
  final BrokerAiDecision decision;
  final VoidCallback onRefresh;

  const _DecisionView({required this.decision, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final Color modeColor = _modeColor(decision.mode);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: BrokerColors.cardDeep,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: modeColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: modeColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.psychology_alt_rounded, color: modeColor),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Broker AI Kararı',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                tooltip: 'Kararı yenile',
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: BrokerColors.textSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: modeColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: modeColor.withValues(alpha: 0.22)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PİYASA MODU',
                  style: TextStyle(
                    color: BrokerColors.textSoft,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  decision.modeLabel,
                  style: TextStyle(
                    color: modeColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  decision.summary,
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  label: 'GÜVEN',
                  value: '%${decision.confidence}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricBox(label: 'RİSK', value: decision.riskLabel),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricBox(
                  label: 'SKOR',
                  value: '${decision.score}/100',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Kararı destekleyen sinyaller',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          ...decision.positiveReasons.map(
            (String reason) => _ReasonRow(
              icon: Icons.check_circle_rounded,
              text: reason,
              color: BrokerColors.green,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Risk sinyalleri',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          ...decision.riskReasons.map(
            (String reason) => _ReasonRow(
              icon: Icons.warning_amber_rounded,
              text: reason,
              color: BrokerColors.orange,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Broker AI v1 • Canlı piyasa verilerinden kural tabanlı konsensüs',
            style: TextStyle(color: BrokerColors.textSoft, fontSize: 10),
          ),
        ],
      ),
    );
  }

  static Color _modeColor(BrokerMarketMode mode) {
    switch (mode) {
      case BrokerMarketMode.gucluAl:
      case BrokerMarketMode.seciciAl:
        return BrokerColors.green;
      case BrokerMarketMode.bekle:
        return BrokerColors.orange;
      case BrokerMarketMode.riskAzalt:
      case BrokerMarketMode.gucluRiskAzalt:
        return BrokerColors.red;
    }
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;

  const _MetricBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: BrokerColors.background.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrokerColors.border.withValues(alpha: 0.70)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: BrokerColors.textMain,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _ReasonRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: BrokerColors.textSoft,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: BrokerColors.cardDeep,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: BrokerColors.border),
      ),
      child: const CircularProgressIndicator(),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorCard({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: BrokerColors.cardDeep,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: BrokerColors.red.withValues(alpha: 0.30)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: BrokerColors.red,
            size: 34,
          ),
          const SizedBox(height: 10),
          const Text(
            'Broker AI kararı oluşturulamadı.',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tekrar dene'),
          ),
        ],
      ),
    );
  }
}
