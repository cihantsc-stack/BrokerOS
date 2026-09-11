import 'package:flutter/material.dart';

import '../../../core/opportunity/opportunity_candidate.dart';
import '../../../core/opportunity/opportunity_comparator_engine.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class OpportunityComparatorCard extends StatefulWidget {
  final String symbol;

  const OpportunityComparatorCard({super.key, required this.symbol});

  @override
  State<OpportunityComparatorCard> createState() =>
      _OpportunityComparatorCardState();
}

class _OpportunityComparatorCardState extends State<OpportunityComparatorCard> {
  late Future<List<OpportunityCandidate>> _future;

  @override
  void initState() {
    super.initState();
    _future = OpportunityComparatorEngine.instance.compare(widget.symbol);
  }

  @override
  void didUpdateWidget(covariant OpportunityComparatorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol) {
      _future = OpportunityComparatorEngine.instance.compare(widget.symbol);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OpportunityCandidate>>(
      future: _future,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<List<OpportunityCandidate>> snapshot,
          ) {
            if (!snapshot.hasData) {
              return const BrokerCard(
                child: SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final List<OpportunityCandidate> items = snapshot.data!;
            final OpportunityCandidate leader = items.first;

            return BrokerCard(
              glow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.compare_arrows_rounded,
                        color: BrokerColors.primary,
                        size: 29,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Fırsat Karşılaştırıcı',
                        style: TextStyle(
                          color: BrokerColors.textMain,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    leader.symbol == widget.symbol
                        ? '${widget.symbol} şu anda karşılaştırmadaki en güçlü fırsat.'
                        : '${leader.symbol}, bugün ${widget.symbol} hissesinden daha güçlü görünüyor.',
                    style: const TextStyle(
                      color: BrokerColors.textSoft,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (int index = 0; index < items.length; index++) ...[
                    _CandidateRow(rank: index + 1, candidate: items[index]),
                    const SizedBox(height: 9),
                  ],
                ],
              ),
            );
          },
    );
  }
}

class _CandidateRow extends StatelessWidget {
  final int rank;
  final OpportunityCandidate candidate;

  const _CandidateRow({required this.rank, required this.candidate});

  @override
  Widget build(BuildContext context) {
    final Color tone = rank == 1
        ? BrokerColors.primary
        : candidate.isCurrent
        ? Colors.orange
        : BrokerColors.textSoft;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '#$rank',
              style: TextStyle(color: tone, fontWeight: FontWeight.w900),
            ),
          ),
          SizedBox(
            width: 72,
            child: Text(
              candidate.symbol,
              style: const TextStyle(
                color: BrokerColors.textMain,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: Text(
              candidate.reason,
              style: const TextStyle(
                color: BrokerColors.textSoft,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            candidate.score.toStringAsFixed(0),
            style: TextStyle(
              color: tone,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
