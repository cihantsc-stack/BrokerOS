import 'package:flutter/material.dart';

import '../../../core/consensus/consensus_engine.dart';
import '../../../core/consensus/consensus_result.dart';
import '../../../core/consensus/consensus_vote.dart';
import '../../../core/providers/provider_manager.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiConfidenceIndexCard extends StatefulWidget {
  final String symbol;
  final ConsensusEngine consensusEngine;

  const AiConfidenceIndexCard({
    super.key,
    required this.symbol,
    required this.consensusEngine,
  });

  @override
  State<AiConfidenceIndexCard> createState() => _AiConfidenceIndexCardState();
}

class _AiConfidenceIndexCardState extends State<AiConfidenceIndexCard> {
  late Future<ConsensusResult> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant AiConfidenceIndexCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.symbol != widget.symbol) {
      _future = _load();
    }
  }

  Future<ConsensusResult> _load() async {
    final bundle = await ProviderManager.instance.load(widget.symbol);

    return widget.consensusEngine.evaluate(
      symbol: widget.symbol,
      bundle: bundle,
    );
  }

  void _refresh() {
    ProviderManager.instance.clearCache();

    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ConsensusResult>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<ConsensusResult> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const BrokerCard(
            child: SizedBox(
              height: 190,
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
                    'AI Güven Endeksi oluşturulamadı.',
                    style: TextStyle(color: BrokerColors.textSoft),
                  ),
                ),
                IconButton(
                  tooltip: 'Yenile',
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          );
        }

        final ConsensusResult result = snapshot.data!;
        final List<ConsensusVote> votes = List<ConsensusVote>.from(result.votes)
          ..sort(
            (ConsensusVote first, ConsensusVote second) =>
                second.confidence.compareTo(first.confidence),
          );

        return BrokerCard(
          glow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.speed_rounded,
                    color: BrokerColors.primary,
                    size: 29,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'AI Güven Endeksi',
                      style: TextStyle(
                        color: BrokerColors.textMain,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Endeksi yenile',
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Ortak kararın hangi AI ajanları tarafından güçlendirildiğini gösterir.',
                style: TextStyle(color: BrokerColors.textSoft, height: 1.4),
              ),
              const SizedBox(height: 16),
              _OverallConfidence(
                confidence: result.confidence,
                signal: result.finalSignal,
                riskLevel: result.riskLevel,
              ),
              const SizedBox(height: 18),
              for (final ConsensusVote vote in votes) ...[
                _AgentConfidenceRow(vote: vote),
                const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _OverallConfidence extends StatelessWidget {
  final int confidence;
  final ConsensusSignal signal;
  final String riskLevel;

  const _OverallConfidence({
    required this.confidence,
    required this.signal,
    required this.riskLevel,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (confidence / 100).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrokerColors.primary.withValues(alpha: 0.17)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  signal.label,
                  style: const TextStyle(
                    color: BrokerColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '%$confidence',
                style: const TextStyle(
                  color: BrokerColors.textMain,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 11,
              backgroundColor: BrokerColors.textSoft.withValues(alpha: 0.10),
              valueColor: const AlwaysStoppedAnimation<Color>(
                BrokerColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Genel güven • Risk: $riskLevel',
              style: const TextStyle(
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

class _AgentConfidenceRow extends StatelessWidget {
  final ConsensusVote vote;

  const _AgentConfidenceRow({required this.vote});

  @override
  Widget build(BuildContext context) {
    final double progress = (vote.confidence / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                vote.agent,
                style: const TextStyle(
                  color: BrokerColors.textMain,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              vote.signal.label,
              style: const TextStyle(
                color: BrokerColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 38,
              child: Text(
                '${vote.confidence}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: BrokerColors.textMain,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
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
