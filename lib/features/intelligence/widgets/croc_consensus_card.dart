import 'package:flutter/material.dart';

import '../../../core/consensus/consensus_engine.dart';
import '../../../core/consensus/consensus_result.dart';
import '../../../core/consensus/consensus_vote.dart';
import '../../../core/copilot/broker_copilot.dart';
import '../../../core/providers/provider_manager.dart';
import '../../../core/timeline/decision_timeline_engine.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class CrocConsensusCard extends StatefulWidget {
  final String symbol;
  final ConsensusEngine consensusEngine;
  final BrokerCopilot brokerCopilot;
  final DecisionTimelineEngine timelineEngine;

  const CrocConsensusCard({
    super.key,
    required this.symbol,
    required this.consensusEngine,
    required this.brokerCopilot,
    required this.timelineEngine,
  });

  @override
  State<CrocConsensusCard> createState() => _CrocConsensusCardState();
}

class _CrocConsensusCardState extends State<CrocConsensusCard> {
  late Future<ConsensusResult> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant CrocConsensusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol) {
      _future = _load();
    }
  }

  Future<ConsensusResult> _load() async {
    final bundle = await ProviderManager.instance.load(widget.symbol);
    final result = widget.consensusEngine.evaluate(
      symbol: widget.symbol,
      bundle: bundle,
    );

    widget.timelineEngine.record(result: result, bundle: bundle);

    return result;
  }

  void _refresh() {
    ProviderManager.instance.clearCache();
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ConsensusResult>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const BrokerCard(
            child: SizedBox(
              height: 150,
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
                    'CROC AI ortak kararı üretilemedi.',
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

        final result = snapshot.data!;
        final copilot = widget.brokerCopilot.explain(result);

        return BrokerCard(
          glow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.hub_rounded,
                    color: BrokerColors.primary,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'CROC AI Consensus',
                      style: TextStyle(
                        color: BrokerColors.textMain,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Kararı yenile',
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      result.finalSignal.label,
                      style: const TextStyle(
                        color: BrokerColors.primary,
                        fontSize: 31,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '%${result.confidence}',
                    style: const TextStyle(
                      color: BrokerColors.textMain,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'Güven skoru • Risk: ${result.riskLevel}',
                style: const TextStyle(
                  color: BrokerColors.textSoft,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              for (final vote in result.votes) ...[
                _VoteRow(vote: vote),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: BrokerColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: BrokerColors.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Text(
                  copilot.standardMessage.body,
                  style: const TextStyle(
                    color: BrokerColors.textMain,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VoteRow extends StatelessWidget {
  final ConsensusVote vote;

  const _VoteRow({required this.vote});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            vote.agent,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            vote.signal.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: BrokerColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        SizedBox(
          width: 42,
          child: Text(
            '%${vote.confidence}',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
