import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/events/ai_event.dart';
import '../../../core/events/ai_event_bus.dart';
import '../../../core/timeline/decision_snapshot.dart';
import '../../../core/timeline/decision_timeline_engine.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';
import 'decision_history_item.dart';
import 'decision_reason_dialog.dart';

class DecisionTimelineCard extends StatefulWidget {
  final String symbol;
  final DecisionTimelineEngine timelineEngine;

  const DecisionTimelineCard({
    super.key,
    required this.symbol,
    required this.timelineEngine,
  });

  @override
  State<DecisionTimelineCard> createState() => _DecisionTimelineCardState();
}

class _DecisionTimelineCardState extends State<DecisionTimelineCard> {
  StreamSubscription<AiEvent>? _subscription;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();

    _subscription = AiEventBus.instance.stream.listen((event) {
      final eventSymbol = event.value<String>('symbol');
      if (eventSymbol == widget.symbol && mounted) {
        setState(() {});
      }
    });

    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = widget.timelineEngine.historyOf(widget.symbol, limit: 8);

    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.timeline_rounded,
                color: BrokerColors.primary,
                size: 29,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'CROC AI Karar Geçmişi',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${history.length} kayıt',
                style: const TextStyle(
                  color: BrokerColors.textSoft,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Consensus kararlarının zaman içindeki değişimi ve gerekçeleri.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.4),
          ),
          const SizedBox(height: 15),
          if (history.isEmpty)
            const _EmptyTimeline()
          else
            for (int index = 0; index < history.length; index++) ...[
              DecisionHistoryItem(
                snapshot: history[index],
                isLatest: index == 0,
                onTap: () => _showReasons(context, history, index),
              ),
              if (index != history.length - 1) const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }

  void _showReasons(
    BuildContext context,
    List<DecisionSnapshot> history,
    int index,
  ) {
    final current = history[index];
    final previous = index + 1 < history.length ? history[index + 1] : null;

    showDialog<void>(
      context: context,
      builder: (_) => DecisionReasonDialog(
        snapshot: current,
        changes: widget.timelineEngine.changesFor(
          current: current,
          previous: previous,
        ),
      ),
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.history_toggle_off_rounded, color: BrokerColors.textSoft),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'İlk consensus kararı üretildiğinde geçmiş burada başlayacak.',
            style: TextStyle(
              color: BrokerColors.textSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
