import 'package:flutter/material.dart';

import '../../core/engine/broker_engine.dart';
import '../../core/models/stock_analysis.dart';
import '../../shared/design/broker_colors.dart';
import '../../shared/glossary/interactive_glossary_text.dart';
import '../../shared/widgets/broker_card.dart';
import '../../shared/widgets/broker_page.dart';

class DecisionCenterScreen extends StatelessWidget {
  const DecisionCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stocks = BrokerEngine.run();
    final strongest = stocks.first;
    final totalSmartMoney = stocks.fold<double>(
      0,
      (sum, item) => sum + (item.smartMoneyFlow ?? 0),
    );

    return BrokerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CrocHeader(),
          const SizedBox(height: 18),
          _LiveMarketStrip(totalSmartMoney: totalSmartMoney),
          const SizedBox(height: 16),
          _MarketHeroCard(stock: strongest),
          const SizedBox(height: 16),
          _AiBriefCard(stock: strongest),
          const SizedBox(height: 16),
          const _MarketSnapshotGrid(),
          const SizedBox(height: 16),
          _OpportunityListCard(stocks: stocks),
          const SizedBox(height: 16),
          _SmartMoneyCard(totalSmartMoney: totalSmartMoney, leader: strongest),
          const SizedBox(height: 16),
          const _RiskDisciplineCard(),
        ],
      ),
    );
  }
}

class _CrocHeader extends StatelessWidget {
  const _CrocHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            gradient: BrokerColors.crocGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: BrokerColors.primary.withOpacity(.25),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: Colors.black,
            size: 34,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CROC AI',
                style: TextStyle(
                  color: BrokerColors.textMain,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .4,
                  height: 1,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'powered by Broker OS',
                style: TextStyle(
                  color: BrokerColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LiveMarketStrip extends StatelessWidget {
  final double totalSmartMoney;

  const _LiveMarketStrip({
    required this.totalSmartMoney,
  });

  String _money(double value) {
    if (value >= 1000000000) {
      return '+${(value / 1000000000).toStringAsFixed(2)} MLR';
    }
    return '+${(value / 1000000).toStringAsFixed(0)} MN';
  }

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      padding: const EdgeInsets.all(14),
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grafiği değil, paranın izini sür.',
            style: TextStyle(
              color: BrokerColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: _LiveMini(title: 'BIST100', value: '+1.82%'),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: _LiveMini(title: 'USD/TL', value: '41.12'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LiveMini(
                  title: 'SMART MONEY',
                  value: _money(totalSmartMoney),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.circle, size: 9, color: BrokerColors.green),
              SizedBox(width: 8),
              Text(
                'CROC AI CANLI',
                style: TextStyle(
                  color: BrokerColors.textSoft,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MarketHeroCard extends StatelessWidget {
  final StockAnalysis stock;

  const _MarketHeroCard({
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            icon: Icons.psychology_alt_rounded,
            title: 'Bugünkü Piyasa Kararı',
          ),
          const SizedBox(height: 16),
          const Text(
            'SEÇİCİ ALIM MODU',
            style: TextStyle(
              color: BrokerColors.primary,
              fontSize: 33,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          InteractiveGlossaryText(
            'Piyasa genelinde Smart Money pozitif. En güçlü aday ${stock.symbol}. Momentum güçlü ama Volatilite orta seviyede. Bu nedenle her hisse için ayrı Stop planı gerekli.',
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  title: 'Güven',
                  value: '%${stock.confidence}',
                  color: BrokerColors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  title: 'Risk',
                  value: stock.risk,
                  color: BrokerColors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  title: 'Skor',
                  value: '${stock.brokerConsensus}',
                  color: BrokerColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiBriefCard extends StatelessWidget {
  final StockAnalysis stock;

  const _AiBriefCard({
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            icon: Icons.smart_toy_rounded,
            title: 'CROC AI Sabah Yorumu',
          ),
          const SizedBox(height: 14),
          InteractiveGlossaryText(
            'Bugün tek işlem yapacak olsam güçlü kurumsal para izini takip ederim. ${stock.symbol} radarın en güçlü adayı. Smart Money pozitif, Momentum güçlü ve Stop disiplini korunursa senaryo destekleniyor.',
          ),
        ],
      ),
    );
  }
}

class _MarketSnapshotGrid extends StatelessWidget {
  const _MarketSnapshotGrid();

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            icon: Icons.monitor_heart_rounded,
            title: 'Piyasa Panoraması',
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MarketBox(
                  title: 'BIST100',
                  value: '+1.82%',
                  color: BrokerColors.green,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MarketBox(
                  title: 'DOLAR/TL',
                  value: '-0.15%',
                  color: BrokerColors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MarketBox(
                  title: 'GRAM ALTIN',
                  value: '+0.65%',
                  color: BrokerColors.green,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MarketBox(
                  title: 'VİOP 30',
                  value: '+1.24%',
                  color: BrokerColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OpportunityListCard extends StatelessWidget {
  final List<StockAnalysis> stocks;

  const _OpportunityListCard({
    required this.stocks,
  });

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            icon: Icons.auto_awesome_rounded,
            title: 'Bugünün Fırsatları',
          ),
          const SizedBox(height: 14),
          ...stocks.take(3).toList().asMap().entries.map(
                (entry) => _OpportunityRow(
                  rank: '${entry.key + 1}',
                  stock: entry.value,
                ),
              ),
        ],
      ),
    );
  }
}

class _SmartMoneyCard extends StatelessWidget {
  final double totalSmartMoney;
  final StockAnalysis leader;

  const _SmartMoneyCard({
    required this.totalSmartMoney,
    required this.leader,
  });

  String _money(double value) {
    if (value >= 1000000000) {
      return '+${(value / 1000000000).toStringAsFixed(2)} Milyar TL';
    }
    return '+${(value / 1000000).toStringAsFixed(0)} Milyon TL';
  }

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            icon: Icons.account_balance_rounded,
            title: 'Kurumsal Para Akışı',
          ),
          const SizedBox(height: 14),
          Text(
            _money(totalSmartMoney),
            style: const TextStyle(
              color: BrokerColors.primary,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          InteractiveGlossaryText(
            'Son 60 dakikada Smart Money tarafı pozitif. ${leader.firstInstitution ?? 'İş Yatırım'}, ${leader.secondInstitution ?? 'Ak Yatırım'} ve ${leader.thirdInstitution ?? 'Yapı Kredi'} net alıcı tarafta.',
          ),
        ],
      ),
    );
  }
}

class _RiskDisciplineCard extends StatelessWidget {
  const _RiskDisciplineCard();

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            icon: Icons.shield_rounded,
            title: 'Bugün Bunları Yapma',
          ),
          SizedBox(height: 14),
          _WarningLine('Stop seviyesi olmadan işlem açma.'),
          _WarningLine('Direnç bölgesinde hacimsiz kırılıma güvenme.'),
          _WarningLine('Volatilite artarken kaldıraçlı işlemde agresif olma.'),
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CardTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: BrokerColors.primary.withOpacity(.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: BrokerColors.primary.withOpacity(.18)),
          ),
          child: Icon(icon, color: BrokerColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _LiveMini extends StatelessWidget {
  final String title;
  final String value;

  const _LiveMini({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft.withOpacity(.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: BrokerColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MiniStat({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft.withOpacity(.75),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MarketBox({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft.withOpacity(.75),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpportunityRow extends StatelessWidget {
  final String rank;
  final StockAnalysis stock;

  const _OpportunityRow({
    required this.rank,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft.withOpacity(.75),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Row(
        children: [
          Text(
            rank,
            style: const TextStyle(
              color: BrokerColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            stock.symbol,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              stock.decision,
              style: const TextStyle(
                color: BrokerColors.textSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${stock.brokerConsensus}',
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

class _WarningLine extends StatelessWidget {
  final String text;

  const _WarningLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: BrokerColors.orange,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(child: InteractiveGlossaryText(text)),
        ],
      ),
    );
  }
}