import 'package:flutter/material.dart';

import '../../desktop_dashboard/models/daily_trade_candidate.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/glossary/interactive_glossary_text.dart';
import '../../../shared/widgets/broker_card.dart';
import 'radar_action_button.dart';
import 'radar_info_box.dart';
import 'radar_metric_box.dart';
import 'radar_score_circle.dart';
import 'radar_sparkline.dart';

class RadarStockCard extends StatelessWidget {
  final DailyTradeCandidate stock;
  final VoidCallback onOpenReport;

  const RadarStockCard({
    super.key,
    required this.stock,
    required this.onOpenReport,
  });

  String get _moneyTlText {
    final value = stock.moneyTlVolume;

    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(2)} Mr ₺';
    }

    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)} Mn ₺';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)} Bin ₺';
    }

    return '${value.toStringAsFixed(0)} ₺';
  }

  String get _moneyVwapText {
    if (stock.moneyVwap <= 0 || stock.livePrice <= 0) {
      return '--';
    }

    return stock.livePrice >= stock.moneyVwap ? 'ÜSTÜ' : 'ALTI';
  }

  String get _moneyRadarDecision {
    if (!stock.moneyRadarAvailable) {
      return 'VERİ YOK';
    }

    if (stock.overboughtScore >= 70) {
      return 'AŞIRI ALIM';
    }

    if (stock.moneyScore >= 70) {
      return 'GÜÇLÜ PARA';
    }

    if (stock.moneyScore >= 50) {
      return 'PARA GİRİŞİ';
    }

    if (stock.moneyScore >= 30) {
      return 'İZLE';
    }

    return 'ZAYIF';
  }

  String get _expectedMove {
    if (stock.livePrice <= 0 || stock.target <= stock.livePrice) {
      return '--';
    }

    final move = ((stock.target - stock.livePrice) / stock.livePrice) * 100;

    return '+%${move.toStringAsFixed(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final change = stock.changePercent;

    final changeColor = change >= 0 ? BrokerColors.green : BrokerColors.red;

    final riskColor = stock.risk.toLowerCase().contains('yüksek')
        ? BrokerColors.red
        : stock.risk.toLowerCase().contains('orta')
        ? BrokerColors.orange
        : BrokerColors.green;

    final decision = stock.crocScore >= 82
        ? 'GÜÇLÜ ADAY'
        : stock.crocScore >= 75
        ? 'SEÇİCİ ADAY'
        : 'İZLE';

    return BrokerCard(
      glow: stock.crocScore >= 82,
      onTap: onOpenReport,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 52, child: RadarSparkline(up: change >= 0)),
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
                          '${stock.livePrice.toStringAsFixed(2)} ₺',
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
                            color: changeColor.withValues(alpha: .14),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: changeColor.withValues(alpha: .22),
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

              RadarScoreCircle(score: stock.crocScore),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: RadarMetricBox(
                  title: 'CROC Kararı',
                  value: decision,
                  color: stock.crocScore >= 75
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
                  title: 'Teknik',
                  value: '${stock.technicalScore}/100',
                  color: BrokerColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          InteractiveGlossaryText(
            'Neden: ${stock.tradeReason}. ${stock.contextLabel}',
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: RadarInfoBox(
                  title: 'Risk / Getiri',
                  value: '1 : ${stock.riskReward.toStringAsFixed(2)}',
                  subtitle: 'Gerçek teknik analiz',
                  icon: Icons.balance_rounded,
                  color: BrokerColors.green,
                ),
              ),
              const SizedBox(width: 9),

              Expanded(
                child: RadarInfoBox(
                  title: 'Beklenen Hareket',
                  value: _expectedMove,
                  subtitle: 'Hedef 1 bazlı',
                  icon: Icons.trending_up_rounded,
                  color: BrokerColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: RadarInfoBox(
                  title: 'Destek',
                  value: stock.support.toStringAsFixed(2),
                  subtitle: 'Teknik seviye',
                  icon: Icons.horizontal_rule_rounded,
                  color: BrokerColors.green,
                ),
              ),
              const SizedBox(width: 9),

              Expanded(
                child: RadarInfoBox(
                  title: 'Stop',
                  value: stock.stop.toStringAsFixed(2),
                  subtitle: 'Risk kontrol',
                  icon: Icons.shield_outlined,
                  color: BrokerColors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: BrokerColors.primary.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: BrokerColors.primary.withValues(alpha: .18),
              ),
            ),
            child: stock.moneyRadarAvailable
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.radar_rounded,
                            size: 18,
                            color: BrokerColors.primary,
                          ),
                          const SizedBox(width: 7),
                          const Expanded(
                            child: Text(
                              'CROC PARA RADARI',
                              style: TextStyle(
                                color: BrokerColors.textMain,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            _moneyRadarDecision,
                            style: TextStyle(
                              color: stock.overboughtScore >= 70
                                  ? BrokerColors.red
                                  : stock.moneyScore >= 50
                                  ? BrokerColors.green
                                  : BrokerColors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadarMetricBox(
                              title: 'Para',
                              value: '${stock.moneyScore}/100',
                              color: stock.moneyScore >= 50
                                  ? BrokerColors.green
                                  : BrokerColors.orange,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: RadarMetricBox(
                              title: '5dk Hacim',
                              value:
                                  '${stock.moneyVolumeRatio.toStringAsFixed(1)}x',
                              color: stock.moneyVolumeRatio >= 2
                                  ? BrokerColors.green
                                  : BrokerColors.primary,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: RadarMetricBox(
                              title: '15dk Teyit',
                              value:
                                  '${stock.moneyVolume15Ratio.toStringAsFixed(1)}x',
                              color: stock.moneyVolume15Ratio >= 2
                                  ? BrokerColors.green
                                  : BrokerColors.primary,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: RadarMetricBox(
                              title: 'TL Hacim',
                              value: _moneyTlText,
                              color: stock.moneyTlVolume >= 50000000
                                  ? BrokerColors.green
                                  : BrokerColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'CMF ${stock.moneyCmf >= 0 ? '+' : ''}'
                        '${stock.moneyCmf.toStringAsFixed(3)}'
                        '  •  VWAP $_moneyVwapText'
                        '  •  RSI ${stock.moneyRsi.toStringAsFixed(1)}'
                        '  •  Aşırı Alım ${stock.overboughtScore}/100',
                        style: TextStyle(
                          color: stock.overboughtScore >= 70
                              ? BrokerColors.red
                              : BrokerColors.textSoft,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    children: [
                      Icon(
                        Icons.radar_rounded,
                        size: 18,
                        color: BrokerColors.orange,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'CROC Para Radarı • intraday veri bekleniyor',
                        style: TextStyle(
                          color: BrokerColors.textSoft,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
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
