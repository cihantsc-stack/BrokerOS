import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiDecisionCenterCard extends StatelessWidget {
  final List<StockAnalysis> stocks;
  final double totalSmartMoney;

  const AiDecisionCenterCard({
    super.key,
    required this.stocks,
    required this.totalSmartMoney,
  });

  @override
  Widget build(BuildContext context) {
    final rankedStocks = List<StockAnalysis>.from(stocks)
      ..sort((a, b) => b.brokerConsensus.compareTo(a.brokerConsensus));

    final movers = stocks.where((item) => item.dailyChange != null).toList();
    final rising = movers.where((item) => (item.dailyChange ?? 0) > 0).length;
    final falling = movers.where((item) => (item.dailyChange ?? 0) < 0).length;
    final breadthBase = rising + falling;
    final breadthScore = breadthBase == 0
        ? 50
        : ((rising / breadthBase) * 100).round();

    final strongest = rankedStocks.isEmpty ? null : rankedStocks.first;
    final topScore = strongest?.brokerConsensus ?? 50;
    final confidence = ((breadthScore * 0.55) + (topScore * 0.45))
        .round()
        .clamp(0, 100);
    final decision = _decisionFor(breadthScore, totalSmartMoney);
    final risk = _riskFor(breadthScore, totalSmartMoney);
    final picks = rankedStocks.take(3).toList();

    return BrokerCard(
      glow: true,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: BrokerColors.primary.withValues(alpha: .11),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: BrokerColors.primary.withValues(alpha: .22),
                  ),
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  color: BrokerColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BUGÜNÜN CROC KARARI',
                      style: TextStyle(
                        color: BrokerColors.textMain,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tek bakışta piyasa yönü ve aksiyon',
                      style: TextStyle(
                        color: BrokerColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: BrokerColors.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: BrokerColors.primary.withValues(alpha: .18),
                  ),
                ),
                child: Text(
                  '%$confidence',
                  style: const TextStyle(
                    color: BrokerColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            decision,
            style: const TextStyle(
              color: BrokerColors.primary,
              fontSize: 30,
              height: 1.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _summaryFor(
              rising: rising,
              falling: falling,
              smartMoney: totalSmartMoney,
              risk: risk,
            ),
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 13,
              height: 1.42,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 16) / 3;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SignalBox(
                    width: width,
                    icon: Icons.show_chart_rounded,
                    label: 'Piyasa',
                    value: '$rising ↑ / $falling ↓',
                    tone: rising >= falling
                        ? BrokerColors.green
                        : BrokerColors.orange,
                  ),
                  const SizedBox(width: 8),
                  _SignalBox(
                    width: width,
                    icon: Icons.account_balance_rounded,
                    label: 'Para Akışı',
                    value: _money(totalSmartMoney),
                    tone: totalSmartMoney >= 0
                        ? BrokerColors.green
                        : BrokerColors.orange,
                  ),
                  const SizedBox(width: 8),
                  _SignalBox(
                    width: width,
                    icon: Icons.shield_outlined,
                    label: 'Risk',
                    value: risk,
                    tone: risk == 'Yüksek'
                        ? BrokerColors.orange
                        : BrokerColors.textMain,
                  ),
                ],
              );
            },
          ),
          if (picks.isNotEmpty) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'ÖNE ÇIKANLAR',
                    style: TextStyle(
                      color: BrokerColors.textMain,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .5,
                    ),
                  ),
                ),
                Text(
                  'CROC skoruna göre',
                  style: TextStyle(
                    color: BrokerColors.textMuted.withValues(alpha: .85),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            ...picks.asMap().entries.map(
              (entry) => _PickRow(rank: entry.key + 1, stock: entry.value),
            ),
          ],
        ],
      ),
    );
  }

  static String _decisionFor(int breadthScore, double smartMoney) {
    if (breadthScore >= 60 && smartMoney > 0) return 'SEÇİCİ ALIM';
    if (breadthScore >= 45 && smartMoney >= 0) return 'TEMKİNLİ İZLE';
    if (breadthScore >= 30) return 'RİSK AZALT';
    return 'SAVUNMA MODU';
  }

  static String _riskFor(int breadthScore, double smartMoney) {
    if (breadthScore < 35 || smartMoney < 0) return 'Yüksek';
    if (breadthScore >= 60 && smartMoney > 0) return 'Düşük';
    return 'Orta';
  }

  static String _summaryFor({
    required int rising,
    required int falling,
    required double smartMoney,
    required String risk,
  }) {
    final flow = smartMoney >= 0 ? 'pozitif' : 'negatif';
    return 'Piyasa $rising yükselen / $falling düşen görünümünde. Kurumsal para akışı $flow, risk seviyesi $risk.';
  }

  static String _money(double value) {
    final abs = value.abs();
    final sign = value >= 0 ? '+' : '-';
    if (abs >= 1000000000)
      return '$sign${(abs / 1000000000).toStringAsFixed(1)} Mr';
    if (abs >= 1000000) return '$sign${(abs / 1000000).toStringAsFixed(1)} Mn';
    if (abs >= 1000) return '$sign${(abs / 1000).toStringAsFixed(0)} B';
    return '$sign${abs.toStringAsFixed(0)}';
  }
}

class _SignalBox extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final String value;
  final Color tone;

  const _SignalBox({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        constraints: const BoxConstraints(minHeight: 82),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: BrokerColors.background.withValues(alpha: .34),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: BrokerColors.border.withValues(alpha: .68)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: tone),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: BrokerColors.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tone,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickRow extends StatelessWidget {
  final int rank;
  final StockAnalysis stock;

  const _PickRow({required this.rank, required this.stock});

  @override
  Widget build(BuildContext context) {
    final change = stock.dailyChange ?? 0;
    final positive = change >= 0;
    final tone = positive ? BrokerColors.green : BrokerColors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: BrokerColors.background.withValues(alpha: .27),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: BrokerColors.border.withValues(alpha: .55)),
      ),
      child: Row(
        children: [
          Container(
            width: 25,
            height: 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: BrokerColors.primary.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              '$rank',
              style: const TextStyle(
                color: BrokerColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.symbol,
                  style: const TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stock.company,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: BrokerColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${positive ? '+' : ''}${change.toStringAsFixed(2)}%',
            style: TextStyle(
              color: tone,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${stock.brokerConsensus}',
            style: const TextStyle(
              color: BrokerColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
