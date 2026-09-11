import 'package:flutter/material.dart';

import '../../../core/scenario/market_scenario.dart';
import '../../../core/scenario/scenario_engine.dart';
import '../../../core/scenario/scenario_snapshot.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiScenarioSimulatorCard extends StatefulWidget {
  final String symbol;

  const AiScenarioSimulatorCard({super.key, required this.symbol});

  @override
  State<AiScenarioSimulatorCard> createState() =>
      _AiScenarioSimulatorCardState();
}

class _AiScenarioSimulatorCardState extends State<AiScenarioSimulatorCard> {
  late Future<ScenarioSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = ScenarioEngine.instance.simulate(widget.symbol);
  }

  @override
  void didUpdateWidget(covariant AiScenarioSimulatorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol) {
      _future = ScenarioEngine.instance.simulate(widget.symbol);
    }
  }

  void _refresh() {
    setState(() {
      _future = ScenarioEngine.instance.simulate(widget.symbol);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ScenarioSnapshot>(
      future: _future,
      builder:
          (BuildContext context, AsyncSnapshot<ScenarioSnapshot> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const BrokerCard(
                child: SizedBox(
                  height: 260,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (!snapshot.hasData) {
              return BrokerCard(
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Senaryo simülasyonu oluşturulamadı.',
                        style: TextStyle(color: BrokerColors.textSoft),
                      ),
                    ),
                    IconButton(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              );
            }

            final ScenarioSnapshot data = snapshot.data!;

            return BrokerCard(
              glow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.alt_route_rounded,
                        color: BrokerColors.primary,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'AI Senaryo Simülatörü • ${data.symbol}',
                          style: const TextStyle(
                            color: BrokerColors.textMain,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: BrokerColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            data.decision,
                            style: const TextStyle(
                              color: BrokerColors.primary,
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          '%${data.confidence.toStringAsFixed(0)} güven',
                          style: const TextStyle(
                            color: BrokerColors.textMain,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (final MarketScenario scenario in data.scenarios) ...[
                    _ScenarioRow(scenario: scenario),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final String item in data.inputs)
                        Chip(label: Text(item)),
                    ],
                  ),
                  const SizedBox(height: 12),
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

class _ScenarioRow extends StatelessWidget {
  final MarketScenario scenario;

  const _ScenarioRow({required this.scenario});

  @override
  Widget build(BuildContext context) {
    final Color tone = switch (scenario.type) {
      MarketScenarioType.bullish => BrokerColors.primary,
      MarketScenarioType.neutral => Colors.orange,
      MarketScenarioType.bearish => BrokerColors.red,
    };

    final String range =
        '${scenario.minReturnPercent >= 0 ? '+' : ''}'
        '${scenario.minReturnPercent.toStringAsFixed(1)}% / '
        '${scenario.maxReturnPercent >= 0 ? '+' : ''}'
        '${scenario.maxReturnPercent.toStringAsFixed(1)}%';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withValues(alpha: 0.13)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '%${scenario.probability.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: tone,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  scenario.type.label,
                  style: TextStyle(
                    color: tone,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  range,
                  style: const TextStyle(
                    color: BrokerColors.textMain,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${scenario.timeHorizon} • ${scenario.explanation}',
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    fontSize: 12,
                    height: 1.35,
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
