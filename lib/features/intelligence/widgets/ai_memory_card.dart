import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/events/ai_event.dart';
import '../../../core/events/ai_event_bus.dart';
import '../../../core/events/ai_event_type.dart';
import '../../../core/memory/ai_memory.dart';
import '../../../core/memory/memory_engine.dart';
import '../../../core/memory/memory_snapshot.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiMemoryCard extends StatefulWidget {
  final String symbol;
  final String decision;
  final int confidence;
  final MemoryEngine memoryEngine;

  const AiMemoryCard({
    super.key,
    required this.symbol,
    required this.decision,
    required this.confidence,
    required this.memoryEngine,
  });

  @override
  State<AiMemoryCard> createState() => _AiMemoryCardState();
}

class _AiMemoryCardState extends State<AiMemoryCard> {
  StreamSubscription<AiEvent>? _subscription;

  AiMemory get _memory => widget.memoryEngine.memoryOf(widget.symbol);

  @override
  void initState() {
    super.initState();

    _subscription = AiEventBus.instance.on(AiEventType.memoryWritten).listen((
      event,
    ) {
      if (event.value<String>('symbol') != widget.symbol) return;
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _record();
    });
  }

  @override
  void didUpdateWidget(covariant AiMemoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.symbol != widget.symbol ||
        oldWidget.decision != widget.decision ||
        oldWidget.confidence != widget.confidence) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _record();
      });
    }
  }

  void _record() {
    widget.memoryEngine.record(
      symbol: widget.symbol,
      decision: widget.decision,
      confidence: widget.confidence,
      reason: 'Broker Council güncel değerlendirmesi.',
    );

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memory = _memory;
    final latestItems = memory.snapshots.reversed.take(5).toList();

    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.memory_rounded, color: BrokerColors.primary, size: 29),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'AI Hafızası',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.symbol} için son kararlar ve güven skorları '
            'Event Bus üzerinden hafızaya kaydediliyor.',
            style: const TextStyle(color: BrokerColors.textSoft, height: 1.45),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  title: 'KAYIT',
                  value: '${memory.snapshots.length}',
                  color: BrokerColors.primary,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _Metric(
                  title: 'İSTİKRAR',
                  value: '%${memory.stability}',
                  color: memory.stability >= 75
                      ? BrokerColors.green
                      : BrokerColors.orange,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _Metric(
                  title: 'ORT. GÜVEN',
                  value: '%${memory.confidenceHistory.average}',
                  color: BrokerColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (latestItems.isEmpty)
            const Text(
              'Henüz hafıza kaydı oluşmadı.',
              style: TextStyle(color: BrokerColors.textSoft),
            )
          else
            for (int index = 0; index < latestItems.length; index++) ...[
              _MemoryRow(snapshot: latestItems[index]),
              if (index != latestItems.length - 1) const SizedBox(height: 9),
            ],
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _Metric({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryRow extends StatelessWidget {
  final MemorySnapshot snapshot;

  const _MemoryRow({required this.snapshot});

  Color get _color {
    if (snapshot.decision.contains('AL')) return BrokerColors.green;
    if (snapshot.decision.contains('SAT')) return BrokerColors.red;
    return BrokerColors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final time =
        '${snapshot.createdAt.hour.toString().padLeft(2, '0')}:'
        '${snapshot.createdAt.minute.toString().padLeft(2, '0')}:'
        '${snapshot.createdAt.second.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              snapshot.decision,
              style: TextStyle(color: _color, fontWeight: FontWeight.w900),
            ),
          ),
          Text(
            '%${snapshot.confidence}',
            style: const TextStyle(
              color: BrokerColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
