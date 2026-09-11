import 'package:flutter/material.dart';

import '../../../core/smart_money/institutional_order.dart';
import '../../../core/smart_money/money_flow_point.dart';
import '../../../core/smart_money/smart_money_engine.dart';
import '../../../core/smart_money/smart_money_snapshot.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class SmartMoneyRadarCard extends StatefulWidget {
  final String symbol;

  const SmartMoneyRadarCard({super.key, required this.symbol});

  @override
  State<SmartMoneyRadarCard> createState() => _SmartMoneyRadarCardState();
}

class _SmartMoneyRadarCardState extends State<SmartMoneyRadarCard> {
  late Future<SmartMoneySnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = SmartMoneyEngine.instance.analyze(widget.symbol);
  }

  @override
  void didUpdateWidget(covariant SmartMoneyRadarCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.symbol != widget.symbol) {
      _future = SmartMoneyEngine.instance.analyze(widget.symbol);
    }
  }

  void _refresh() {
    setState(() {
      _future = SmartMoneyEngine.instance.analyze(widget.symbol);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SmartMoneySnapshot>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<SmartMoneySnapshot> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const BrokerCard(
            child: SizedBox(
              height: 260,
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
                    'Smart Money analizi oluşturulamadı.',
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

        final SmartMoneySnapshot data = snapshot.data!;

        return BrokerCard(
          glow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.radar_rounded,
                    color: BrokerColors.primary,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Smart Money Radar PRO • ${data.symbol}',
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
                'Kurumsal para, büyük emir ve gizli toplama sinyallerini tek merkezde izler.',
                style: TextStyle(color: BrokerColors.textSoft, height: 1.4),
              ),
              const SizedBox(height: 16),
              _ScoreGrid(data: data),
              const SizedBox(height: 16),
              _LargeOrderPanel(data: data),
              const SizedBox(height: 16),
              _MoneyFlowPanel(points: data.moneyFlow),
              const SizedBox(height: 16),
              const Text(
                'Kurum Hareketleri',
                style: TextStyle(
                  color: BrokerColors.textMain,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              for (final InstitutionalOrder item in data.institutions) ...[
                _InstitutionRow(order: item),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 16),
              _AiComment(comment: data.aiComment),
            ],
          ),
        );
      },
    );
  }
}

class _ScoreGrid extends StatelessWidget {
  final SmartMoneySnapshot data;

  const _ScoreGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _GaugeBox(
          title: 'Gizli Toplama',
          value: data.hiddenAccumulationScore,
          footer: 'Kurumsal birikim olasılığı',
          positive: true,
        ),
        _GaugeBox(
          title: 'Dağıtım Riski',
          value: data.distributionRisk,
          footer: 'Satış baskısı ihtimali',
          positive: false,
        ),
      ],
    );
  }
}

class _GaugeBox extends StatelessWidget {
  final String title;
  final double value;
  final String footer;
  final bool positive;

  const _GaugeBox({
    required this.title,
    required this.value,
    required this.footer,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final Color tone = positive
        ? BrokerColors.primary
        : value >= 60
        ? BrokerColors.red
        : Colors.orange;

    return Container(
      width: 275,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: tone.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (value / 100).clamp(0.0, 1.0),
                    minHeight: 11,
                    backgroundColor: BrokerColors.textSoft.withValues(
                      alpha: 0.10,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(tone),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${value.toStringAsFixed(0)}/100',
                style: TextStyle(color: tone, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            footer,
            style: const TextStyle(color: BrokerColors.textSoft, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _LargeOrderPanel extends StatelessWidget {
  final SmartMoneySnapshot data;

  const _LargeOrderPanel({required this.data});

  @override
  Widget build(BuildContext context) {
    final String hour = data.largeOrderTime.hour.toString().padLeft(2, '0');
    final String minute = data.largeOrderTime.minute.toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: BrokerColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: BrokerColors.primary, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Büyük Emir Yakalandı',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$hour:$minute • '
                  '${data.largeOrderLots.toStringAsFixed(0)} lot',
                  style: const TextStyle(color: BrokerColors.textSoft),
                ),
              ],
            ),
          ),
          Text(
            data.largeOrderSide.label,
            style: const TextStyle(
              color: BrokerColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyFlowPanel extends StatelessWidget {
  final List<MoneyFlowPoint> points;

  const _MoneyFlowPanel({required this.points});

  @override
  Widget build(BuildContext context) {
    double maxValue = 1.0;

    for (final MoneyFlowPoint point in points) {
      if (point.netFlowMillion > maxValue) {
        maxValue = point.netFlowMillion;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Son 30 Dakika Para Akışı',
          style: TextStyle(
            color: BrokerColors.textMain,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final MoneyFlowPoint point in points)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Container(
                      height: 20 + (point.netFlowMillion / maxValue) * 80,
                      decoration: BoxDecoration(
                        color: BrokerColors.primary.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Net giriş: +${points.last.netFlowMillion.toStringAsFixed(1)} milyon TL',
          style: const TextStyle(
            color: BrokerColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _InstitutionRow extends StatelessWidget {
  final InstitutionalOrder order;

  const _InstitutionRow({required this.order});

  @override
  Widget build(BuildContext context) {
    final bool isBuy = order.side == InstitutionalOrderSide.buy;
    final Color tone = isBuy ? BrokerColors.primary : BrokerColors.red;

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: tone.withValues(alpha: 0.11)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              order.institution,
              style: const TextStyle(
                color: BrokerColors.textMain,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '${order.netAmountMillion >= 0 ? '+' : ''}'
            '${order.netAmountMillion.toStringAsFixed(1)} Mn',
            style: TextStyle(color: tone, fontWeight: FontWeight.w900),
          ),
        ],
      ),
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
                  'CROC AI Yorumu',
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
