import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/alerts/ai_alarm_engine.dart';
import '../../../core/alerts/ai_alert.dart';
import '../../../core/events/ai_event.dart';
import '../../../core/events/ai_event_bus.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiAlarmCenterCard extends StatefulWidget {
  final String symbol;
  final AiAlarmEngine alarmEngine;

  const AiAlarmCenterCard({
    super.key,
    required this.symbol,
    required this.alarmEngine,
  });

  @override
  State<AiAlarmCenterCard> createState() => _AiAlarmCenterCardState();
}

class _AiAlarmCenterCardState extends State<AiAlarmCenterCard> {
  StreamSubscription<AiEvent>? _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = AiEventBus.instance.stream.listen((event) {
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
    final alerts = widget.alarmEngine.alertsOf(widget.symbol);
    final unread = widget.alarmEngine.unreadCount(widget.symbol);

    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active_rounded,
                color: BrokerColors.primary,
                size: 29,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'AI Alarm Merkezi',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (unread > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: BrokerColors.red.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: BrokerColors.red.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Text(
                    '$unread YENİ',
                    style: const TextStyle(
                      color: BrokerColors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Karar, güven, risk ve provider değişimleri otomatik izleniyor.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.45),
          ),
          const SizedBox(height: 16),
          if (alerts.isEmpty)
            const _EmptyState()
          else ...[
            for (
              int index = 0;
              index < alerts.length && index < 5;
              index++
            ) ...[
              _AlertRow(alert: alerts[index]),
              if (index != alerts.length - 1 && index != 4)
                const SizedBox(height: 9),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Toplam ${alerts.length} alarm kaydı',
                    style: const TextStyle(
                      color: BrokerColors.textSoft,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.alarmEngine.markAllRead(widget.symbol);
                    setState(() {});
                  },
                  child: const Text('Tümünü okundu yap'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.notifications_none_rounded, color: BrokerColors.textSoft),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Henüz alarm oluşmadı. Yeni AI olayları burada görünecek.',
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

class _AlertRow extends StatelessWidget {
  final AiAlert alert;

  const _AlertRow({required this.alert});

  Color get _color {
    switch (alert.severity) {
      case AiAlertSeverity.critical:
        return BrokerColors.red;
      case AiAlertSeverity.warning:
        return BrokerColors.orange;
      case AiAlertSeverity.info:
        return BrokerColors.primary;
    }
  }

  IconData get _icon {
    switch (alert.severity) {
      case AiAlertSeverity.critical:
        return Icons.warning_amber_rounded;
      case AiAlertSeverity.warning:
        return Icons.bolt_rounded;
      case AiAlertSeverity.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time =
        '${alert.createdAt.hour.toString().padLeft(2, '0')}:'
        '${alert.createdAt.minute.toString().padLeft(2, '0')}:'
        '${alert.createdAt.second.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: alert.isRead ? 0.03 : 0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _color.withValues(alpha: alert.isRead ? 0.10 : 0.22),
        ),
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
                        alert.title,
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  alert.description,
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
