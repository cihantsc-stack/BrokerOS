import 'package:flutter/material.dart';

import '../../../core/hidden_structure/hidden_structure_engine.dart';
import '../../../core/hidden_structure/hidden_structure_signal.dart';
import '../../../core/hidden_structure/hidden_structure_snapshot.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class HiddenStructureCard extends StatefulWidget {
  final String symbol;

  const HiddenStructureCard({super.key, required this.symbol});

  @override
  State<HiddenStructureCard> createState() => _HiddenStructureCardState();
}

class _HiddenStructureCardState extends State<HiddenStructureCard> {
  late Future<HiddenStructureSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = HiddenStructureEngine.instance.analyze(widget.symbol);
  }

  @override
  void didUpdateWidget(covariant HiddenStructureCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.symbol != widget.symbol) {
      _future = HiddenStructureEngine.instance.analyze(widget.symbol);
    }
  }

  void _refresh() {
    setState(() {
      _future = HiddenStructureEngine.instance.analyze(widget.symbol);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HiddenStructureSnapshot>(
      future: _future,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<HiddenStructureSnapshot> snapshot,
          ) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const BrokerCard(
                child: SizedBox(
                  height: 250,
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
                        'Gizli yapı analizi oluşturulamadı.',
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

            final HiddenStructureSnapshot data = snapshot.data!;

            return BrokerCard(
              glow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_tree_rounded,
                        color: BrokerColors.primary,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Gizli Yapı PRO • ${data.symbol}',
                          style: const TextStyle(
                            color: BrokerColors.textMain,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Analizi yenile',
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Fiyatın arkasındaki olası pozisyon, lot ve oyuncu değişimini inceler.',
                    style: TextStyle(color: BrokerColors.textSoft, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  _OverallPanel(data: data),
                  const SizedBox(height: 16),
                  for (final HiddenStructureSignal signal in data.signals) ...[
                    _SignalRow(signal: signal),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 8),
                  const Text(
                    'Tespit Edilen İzler',
                    style: TextStyle(
                      color: BrokerColors.textMain,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final String evidence in data.evidence) ...[
                    _EvidenceRow(text: evidence),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 10),
                  _AiComment(comment: data.aiComment),
                ],
              ),
            );
          },
    );
  }
}

class _OverallPanel extends StatelessWidget {
  final HiddenStructureSnapshot data;

  const _OverallPanel({required this.data});

  @override
  Widget build(BuildContext context) {
    final double progress = (data.overallScore / 100).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrokerColors.primary.withValues(alpha: 0.17)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.marketMode,
                  style: const TextStyle(
                    color: BrokerColors.primary,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${data.overallScore.toStringAsFixed(0)}/100',
                style: const TextStyle(
                  color: BrokerColors.textMain,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
        ],
      ),
    );
  }
}

class _SignalRow extends StatelessWidget {
  final HiddenStructureSignal signal;

  const _SignalRow({required this.signal});

  @override
  Widget build(BuildContext context) {
    final Color tone = _toneFor(signal.level);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withValues(alpha: 0.13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  signal.title,
                  style: const TextStyle(
                    color: BrokerColors.textMain,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${signal.score.toStringAsFixed(0)} • '
                '${signal.level.label}',
                style: TextStyle(
                  color: tone,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (signal.score / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: BrokerColors.textSoft.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation<Color>(tone),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            signal.description,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Color _toneFor(HiddenStructureLevel level) {
    switch (level) {
      case HiddenStructureLevel.veryHigh:
      case HiddenStructureLevel.high:
        return BrokerColors.primary;
      case HiddenStructureLevel.medium:
        return Colors.orange;
      case HiddenStructureLevel.low:
        return BrokerColors.red;
    }
  }
}

class _EvidenceRow extends StatelessWidget {
  final String text;

  const _EvidenceRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_circle_rounded,
            color: BrokerColors.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: BrokerColors.textSoft, height: 1.35),
          ),
        ),
      ],
    );
  }
}

class _AiComment extends StatelessWidget {
  final String comment;

  const _AiComment({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.psychology_alt_rounded, color: BrokerColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CROC AI Yapı Yorumu',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  comment,
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    height: 1.45,
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
