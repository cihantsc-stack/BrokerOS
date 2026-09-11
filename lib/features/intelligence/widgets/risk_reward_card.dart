import 'package:flutter/material.dart';

import '../../../core/risk/risk_reward_engine.dart';
import '../../../core/risk/risk_reward_snapshot.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class RiskRewardCard extends StatefulWidget {
  final String symbol;

  const RiskRewardCard({super.key, required this.symbol});

  @override
  State<RiskRewardCard> createState() => _RiskRewardCardState();
}

class _RiskRewardCardState extends State<RiskRewardCard> {
  late Future<RiskRewardSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = RiskRewardEngine.instance.analyze(widget.symbol);
  }

  @override
  void didUpdateWidget(covariant RiskRewardCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol) {
      _future = RiskRewardEngine.instance.analyze(widget.symbol);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RiskRewardSnapshot>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<RiskRewardSnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const BrokerCard(
            child: SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final RiskRewardSnapshot data = snapshot.data!;

        return BrokerCard(
          glow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.balance_rounded,
                    color: BrokerColors.primary,
                    size: 29,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Risk / Ödül Motoru',
                    style: TextStyle(
                      color: BrokerColors.textMain,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      title: 'RİSK',
                      value: data.riskScore,
                      tone: BrokerColors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Metric(
                      title: 'ÖDÜL',
                      value: data.rewardScore,
                      tone: BrokerColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  _Tag(label: 'Oran ${data.ratio.toStringAsFixed(2)}'),
                  _Tag(label: 'Stop ${data.stopPercent.toStringAsFixed(1)}%'),
                  _Tag(
                    label:
                        'Hedef 1 +${data.firstTargetPercent.toStringAsFixed(1)}%',
                  ),
                  _Tag(
                    label:
                        'Hedef 2 +${data.secondTargetPercent.toStringAsFixed(1)}%',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                data.strategy,
                style: const TextStyle(
                  color: BrokerColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                data.aiComment,
                style: const TextStyle(
                  color: BrokerColors.textSoft,
                  height: 1.45,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Metric extends StatelessWidget {
  final String title;
  final double value;
  final Color tone;

  const _Metric({required this.title, required this.value, required this.tone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: tone, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 9),
          LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: BrokerColors.textSoft.withValues(alpha: 0.10),
            valueColor: AlwaysStoppedAnimation<Color>(tone),
          ),
          const SizedBox(height: 7),
          Text(
            value.toStringAsFixed(1),
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

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: BrokerColors.textMain,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
