import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/ai/council/council_result.dart';
import '../../../core/events/ai_event.dart';
import '../../../core/events/ai_event_bus.dart';
import '../../../core/events/ai_event_coordinator.dart';
import '../../../core/events/ai_event_type.dart';
import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiEventStreamCard extends StatefulWidget {
  final StockAnalysis stock;
  final CouncilResult council;

  const AiEventStreamCard({
    super.key,
    required this.stock,
    required this.council,
  });

  @override
  State<AiEventStreamCard> createState() => _AiEventStreamCardState();
}

class _AiEventStreamCardState extends State<AiEventStreamCard> {
  final List<AiEvent> _events = <AiEvent>[];
  StreamSubscription<AiEvent>? _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = AiEventBus.instance.stream.listen((event) {
      final symbol = event.value<String>('symbol');
      if (symbol != null && symbol != widget.stock.symbol) return;

      if (!mounted) return;
      setState(() {
        _events.insert(0, event);
        if (_events.length > 6) {
          _events.removeRange(6, _events.length);
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runCoordinator();
    });
  }

  @override
  void didUpdateWidget(covariant AiEventStreamCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.stock.symbol != widget.stock.symbol ||
        oldWidget.council.finalDecision != widget.council.finalDecision ||
        oldWidget.council.confidence != widget.council.confidence) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _runCoordinator();
      });
    }
  }

  void _runCoordinator() {
    if (!mounted) return;

    AiEventCoordinator.process(stock: widget.stock, council: widget.council);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.hub_rounded, color: BrokerColors.primary, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Dynamic AI Event Stream',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _LiveBadge(),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Council, Action Center, alarm ve güven motorları '
            'aynı Event Bus üzerinden konuşuyor.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.45),
          ),
          const SizedBox(height: 16),
          if (_events.isEmpty)
            const _WaitingRow()
          else
            for (int index = 0; index < _events.length; index++) ...[
              _EventRow(event: _events[index]),
              if (index != _events.length - 1) const SizedBox(height: 9),
            ],
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: BrokerColors.green.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: BrokerColors.green.withValues(alpha: 0.22)),
      ),
      child: const Text(
        'EVENT BUS',
        style: TextStyle(
          color: BrokerColors.green,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _WaitingRow extends StatelessWidget {
  const _WaitingRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: BrokerColors.primary,
          ),
        ),
        SizedBox(width: 10),
        Text(
          'AI olayları başlatılıyor...',
          style: TextStyle(
            color: BrokerColors.textMain,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  final AiEvent event;

  const _EventRow({required this.event});

  Color get _color {
    switch (event.type) {
      case AiEventType.alertCreated:
      case AiEventType.riskChanged:
        return BrokerColors.red;
      case AiEventType.decisionChanged:
      case AiEventType.confidenceChanged:
        return BrokerColors.orange;
      case AiEventType.councilEvaluated:
      case AiEventType.actionCreated:
        return BrokerColors.green;
      default:
        return BrokerColors.primary;
    }
  }

  IconData get _icon {
    switch (event.type) {
      case AiEventType.alertCreated:
        return Icons.notifications_active_rounded;
      case AiEventType.decisionChanged:
        return Icons.change_circle_rounded;
      case AiEventType.confidenceChanged:
        return Icons.trending_up_rounded;
      case AiEventType.actionCreated:
        return Icons.gps_fixed_rounded;
      case AiEventType.councilEvaluated:
        return Icons.groups_2_rounded;
      default:
        return Icons.bolt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time =
        '${event.occurredAt.hour.toString().padLeft(2, '0')}:'
        '${event.occurredAt.minute.toString().padLeft(2, '0')}:'
        '${event.occurredAt.second.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: _color, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          color: BrokerColors.textMain,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        color: BrokerColors.textSoft,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  event.description,
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
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
