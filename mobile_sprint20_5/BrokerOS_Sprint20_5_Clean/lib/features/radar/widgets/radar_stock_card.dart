import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/glossary/interactive_glossary_text.dart';
import '../../../shared/widgets/broker_card.dart';
import 'radar_action_button.dart';
import 'radar_info_box.dart';
import 'radar_institution_box.dart';
import 'radar_metric_box.dart';
import 'radar_score_circle.dart';
import 'radar_sparkline.dart';

class RadarStockCard extends StatelessWidget {
  final StockAnalysis stock;
  final VoidCallback onOpenReport;

  const RadarStockCard({
    super.key,
    required this.stock,
    required this.onOpenReport,
  });

  String _money(double? value) {
    if (value == null) return '--';
    if (value >= 1000000000) {
      return '+${(value / 1000000000).toStringAsFixed(2)} Milyar';
    }
    if (value >= 1000000) {
      return '+${(value / 1000000).toStringAsFixed(0)} Milyon';
    }
    return '+${value.toStringAsFixed(0)}';
  }

  String get _expectedMove {
    if (stock.symbol == 'ASELS') return '+%7.2';
    if (stock.symbol == 'THYAO') return '+%5.8';
    return '+%4.4';
  }

  @override
  Widget build(BuildContext context) {
    final change = stock.dailyChange ?? 0;
    final changeColor = change >= 0 ? BrokerColors.green : BrokerColors.red;
    final riskColor =
        stock.risk == 'Orta' ? BrokerColors.orange : BrokerColors.green;

    return BrokerCard(
      glow: stock.aiScore >= 90,
      onTap: onOpenReport,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 52,
            child: RadarSparkline(up: change >= 0),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.symbol,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: BrokerColors.primary,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${stock.lastPrice?.toStringAsFixed(2) ?? '--'} ₺',
                          style: const TextStyle(
                            color: BrokerColors.textMain,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: changeColor.withOpacity(.14),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: changeColor.withOpacity(.22),
                            ),
                          ),
                          child: Text(
                            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
                            style: TextStyle(
                              color: changeColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stock.company,
                      style: const TextStyle(
                        color: BrokerColors.textSoft,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              RadarScoreCircle(score: stock.aiScore),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: RadarMetricBox(
                  title: 'Karar',
                  value: stock.decision,
                  color: stock.decision.contains('AL')
                      ? BrokerColors.green
                      : BrokerColors.orange,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: RadarMetricBox(
                  title: 'Risk',
                  value: stock.risk,
                  color: riskColor,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: RadarMetricBox(
                  title: 'Güven',
                  value: '%${stock.confidence}',
                  color: BrokerColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          InteractiveGlossaryText(
            'Neden: ${stock.reasons.join(", ")}. Smart Money ve Momentum birlikte okunur.',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: RadarInfoBox(
                  title: 'Kurumsal Para',
                  value: _money(stock.smartMoneyFlow),
                  subtitle: 'Son 60 dk',
                  icon: Icons.account_balance_rounded,
                  color: BrokerColors.green,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: RadarInfoBox(
                  title: 'Beklenen Hareket',
                  value: _expectedMove,
                  subtitle: '3-5 Gün',
                  icon: Icons.trending_up_rounded,
                  color: BrokerColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          RadarInstitutionBox(
            first: stock.firstInstitution ?? 'İş Yatırım',
            second: stock.secondInstitution ?? 'Ak Yatırım',
            third: stock.thirdInstitution ?? 'Yapı Kredi',
          ),
          const SizedBox(height: 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const RadarActionButton(
                icon: Icons.star_border_rounded,
                text: 'Favori',
              ),
              const RadarActionButton(
                icon: Icons.notifications_none_rounded,
                text: 'Alarm',
              ),
              const RadarActionButton(
                icon: Icons.show_chart_rounded,
                text: 'Grafik',
              ),
              RadarActionButton(
                icon: Icons.psychology_alt_rounded,
                text: 'AI',
                onTap: onOpenReport,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
