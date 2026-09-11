import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/events/ai_event.dart';
import '../../../core/events/ai_event_bus.dart';
import '../../../core/events/ai_event_type.dart';
import '../../../core/memory/memory_engine.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class StabilityGaugeCard extends StatefulWidget {
  final String symbol;
  final MemoryEngine memoryEngine;

  const StabilityGaugeCard({
    super.key,
    required this.symbol,
    required this.memoryEngine,
  });

  @override
  State<StabilityGaugeCard> createState() => _StabilityGaugeCardState();
}

class _StabilityGaugeCardState extends State<StabilityGaugeCard> {
  StreamSubscription<AiEvent>? _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = AiEventBus.instance.on(AiEventType.memoryWritten).listen((
      event,
    ) {
      if (event.value<String>('symbol') != widget.symbol) return;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memory = widget.memoryEngine.memoryOf(widget.symbol);
    final stability = memory.stability;
    final color = stability >= 80
        ? BrokerColors.green
        : stability >= 55
        ? BrokerColors.orange
        : BrokerColors.red;

    final label = stability >= 90
        ? 'Çok Kararlı'
        : stability >= 75
        ? 'Kararlı'
        : stability >= 55
        ? 'Değişken'
        : 'Yüksek Çatışma';

    final explanation = memory.snapshots.length <= 1
        ? 'İlk hafıza kaydı oluştu. Yeni kararlarla istikrar daha anlamlı hale gelecek.'
        : '${memory.snapshots.length} kayıt içinde '
              '${memory.decisionHistory.changeCount} karar değişimi tespit edildi.';

    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.speed_rounded, color: BrokerColors.primary, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'AI Karar İstikrarı',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '%$stability',
                style: TextStyle(
                  color: color,
                  fontSize: 43,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: stability / 100,
              minHeight: 13,
              backgroundColor: BrokerColors.borderSoft,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 11),
          Text(
            explanation,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
