import 'package:flutter/material.dart';

import '../../../core/models/ai_decision.dart';
import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiEventLogCard extends StatelessWidget {
  final StockAnalysis stock;
  final AiDecision decision;

  const AiEventLogCard({
    super.key,
    required this.stock,
    required this.decision,
  });

  @override
  Widget build(BuildContext context) {
    final events = <_AiEvent>[
      const _AiEvent(
        time: '09:30',
        title: 'CROC AI analizi başlattı',
        description: 'Teknik, risk ve para akışı motorları çalıştırıldı.',
        color: BrokerColors.primary,
      ),
      _AiEvent(
        time: '09:42',
        title: 'Smart Money kontrol edildi',
        description: 'Skor ${stock.smartMoneyScore}/100 olarak hesaplandı.',
        color: stock.smartMoneyScore >= 80
            ? BrokerColors.green
            : BrokerColors.orange,
      ),
      _AiEvent(
        time: '09:46',
        title: 'Karar üretildi',
        description:
            '${decision.decision} • güven %${decision.confidence} • risk ${decision.risk}.',
        color: decision.decision.contains('AL')
            ? BrokerColors.green
            : BrokerColors.orange,
      ),
      _AiEvent(
        time: '10:00',
        title: 'İşlem planı hazır',
        description:
            'Stop ${stock.stop.toStringAsFixed(2)}, ilk hedef ${stock.target1.toStringAsFixed(2)}.',
        color: BrokerColors.primary,
      ),
    ];

    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                color: BrokerColors.primary,
                size: 28,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'AI Olay Günlüğü',
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
          for (int index = 0; index < events.length; index++)
            _EventRow(
              event: events[index],
              isLast: index == events.length - 1,
            ),
        ],
      ),
    );
  }
}

class _AiEvent {
  final String time;
  final String title;
  final String description;
  final Color color;

  const _AiEvent({
    required this.time,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _EventRow extends StatelessWidget {
  final _AiEvent event;
  final bool isLast;

  const _EventRow({
    required this.event,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              event.time,
              style: TextStyle(
                color: event.color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(
            width: 22,
            child: Column(
              children: [
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: event.color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: BrokerColors.borderSoft,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: BrokerColors.textMain,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
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
          ),
        ],
      ),
    );
  }
}
