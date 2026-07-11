import 'package:flutter/material.dart';

import '../../shared/design/broker_colors.dart';
import '../../shared/glossary/interactive_glossary_text.dart';
import '../../shared/widgets/broker_card.dart';
import '../../shared/widgets/broker_page.dart';

class DecisionCenterScreen extends StatelessWidget {
  const DecisionCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CrocCommandHeader(),
          SizedBox(height: 14),
          _LiveMarketStrip(),
          SizedBox(height: 14),
          _MarketHeroCard(),
          SizedBox(height: 14),
          _TodayMissionCard(),
          SizedBox(height: 14),
          _AiBriefCard(),
          SizedBox(height: 14),
          _MarketSnapshotGrid(),
          SizedBox(height: 14),
          _OpportunityListCard(),
          SizedBox(height: 14),
          _SmartMoneyCard(),
          SizedBox(height: 14),
          _InstitutionFlowCard(),
          SizedBox(height: 14),
          _RiskDisciplineCard(),
        ],
      ),
    );
  }
}

class _CrocCommandHeader extends StatelessWidget {
  const _CrocCommandHeader();

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      glow: true,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: BrokerColors.crocGradient,
                  borderRadius: BorderRadius.circular(19),
                  boxShadow: [
                    BoxShadow(
                      color: BrokerColors.primary.withOpacity(.25),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.black, size: 30),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CROC AI',
                      style: TextStyle(
                        color: BrokerColors.textMain,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.8,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'POWERED BY BROKER OS',
                      style: TextStyle(
                        color: BrokerColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
              _LivePill(),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Grafiği değil, paranın izini sür.',
            style: TextStyle(
              color: BrokerColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Günaydın Cihan. Bugün piyasada 3 fırsat, 2 risk ve 1 kritik alarm var.',
            style: TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: BrokerColors.primary.withOpacity(.11),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: BrokerColors.primary.withOpacity(.22)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: BrokerColors.primary, size: 8),
          SizedBox(width: 6),
          Text(
            'CANLI',
            style: TextStyle(
              color: BrokerColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveMarketStrip extends StatelessWidget {
  const _LiveMarketStrip();

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: const [
          Expanded(child: _TickerMini(title: 'BIST100', value: '+1.82%', color: BrokerColors.green)),
          SizedBox(width: 8),
          Expanded(child: _TickerMini(title: 'USD/TL', value: '41.12', color: BrokerColors.blue)),
          SizedBox(width: 8),
          Expanded(child: _TickerMini(title: 'ALTIN', value: '+0.65%', color: BrokerColors.orange)),
        ],
      ),
    );
  }
}

class _TickerMini extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _TickerMini({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft.withOpacity(.62),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: BrokerColors.textMuted, fontSize: 10, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _MarketHeroCard extends StatelessWidget {
  const _MarketHeroCard();

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(icon: Icons.auto_graph_rounded, title: 'Bugünkü Piyasa Kararı'),
          const SizedBox(height: 13),
          const Text(
            'SEÇİCİ ALIM MODU',
            style: TextStyle(color: BrokerColors.primary, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -.7),
          ),
          const SizedBox(height: 10),
          const InteractiveGlossaryText(
            'Piyasa genelinde Smart Money pozitif. Momentum güçlü ama Volatilite orta seviyede. Bu nedenle her hisse için ayrı Stop planı gerekli.',
          ),
          const SizedBox(height: 17),
          Row(
            children: const [
              Expanded(child: _MiniStat(title: 'Güven', value: '%92', color: BrokerColors.green)),
              SizedBox(width: 9),
              Expanded(child: _MiniStat(title: 'Risk', value: 'Orta', color: BrokerColors.orange)),
              SizedBox(width: 9),
              Expanded(child: _MiniStat(title: 'Mod', value: 'Atak', color: BrokerColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TodayMissionCard extends StatelessWidget {
  const _TodayMissionCard();

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _CardTitle(icon: Icons.checklist_rounded, title: 'Bugünün Görevleri'),
          SizedBox(height: 12),
          _MissionLine('BIST30 içinde kurumsal alımı güçlü hisseleri izle.'),
          _MissionLine('Direnç bölgesinde hacimsiz kırılımlara atlama.'),
          _MissionLine('Stop seviyesi olmadan hiçbir işlem açma.'),
          _MissionLine('Smart Money çıkışa dönerse pozisyonu küçült.'),
        ],
      ),
    );
  }
}

class _AiBriefCard extends StatelessWidget {
  const _AiBriefCard();

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _CardTitle(icon: Icons.smart_toy_rounded, title: 'CROC AI Sabah Yorumu'),
          SizedBox(height: 12),
          InteractiveGlossaryText(
            'Bugün tek işlem yapacak olsam güçlü kurumsal para izini takip ederim. ASELS ve THYAO radarımda. EREGL tarafında Momentum zayıf kaldığı için beklemek daha sağlıklı.',
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
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(icon: Icons.monitor_heart_rounded, title: 'Piyasa Panoraması'),
          const SizedBox(height: 12),
          Row(children: const [
            Expanded(child: _MarketBox(title: 'BIST100', value: '+1.82%', color: BrokerColors.green)),
            SizedBox(width: 9),
            Expanded(child: _MarketBox(title: 'DOLAR/TL', value: '-0.15%', color: BrokerColors.red)),
          ]),
          const SizedBox(height: 9),
          Row(children: const [
            Expanded(child: _MarketBox(title: 'GRAM ALTIN', value: '+0.65%', color: BrokerColors.green)),
            SizedBox(width: 9),
            Expanded(child: _MarketBox(title: 'VİOP 30', value: '+1.24%', color: BrokerColors.green)),
          ]),
        ],
      ),
    );
  }
}

class _OpportunityListCard extends StatelessWidget {
  const _OpportunityListCard();

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _CardTitle(icon: Icons.auto_awesome_rounded, title: 'Bugünün Fırsatları'),
          SizedBox(height: 12),
          _OpportunityRow(rank: '1', symbol: 'ASELS', note: 'Güçlü alım izi', score: '94'),
          _OpportunityRow(rank: '2', symbol: 'THYAO', note: 'Kurumlar izliyor', score: '89'),
          _OpportunityRow(rank: '3', symbol: 'AKBNK', note: 'Banka momentumu', score: '86'),
        ],
      ),
    );
  }
}

class _SmartMoneyCard extends StatelessWidget {
  const _SmartMoneyCard();

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _CardTitle(icon: Icons.account_balance_rounded, title: 'Kurumsal Para Akışı'),
          SizedBox(height: 12),
          Text('+1.24 Milyar TL', style: TextStyle(color: BrokerColors.primary, fontSize: 28, fontWeight: FontWeight.w900)),
          SizedBox(height: 7),
          InteractiveGlossaryText('Son 60 dakikada Smart Money tarafı pozitif. İş Yatırım, Yapı Kredi ve Ak Yatırım net alıcı tarafta.'),
        ],
      ),
    );
  }
}

class _InstitutionFlowCard extends StatelessWidget {
  const _InstitutionFlowCard();

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _CardTitle(icon: Icons.timeline_rounded, title: 'Kurumsal Hareketler'),
          SizedBox(height: 12),
          _InstitutionLine(time: '09:42', name: 'İş Yatırım', action: '+423M'),
          _InstitutionLine(time: '10:05', name: 'Ak Yatırım', action: '+198M'),
          _InstitutionLine(time: '10:28', name: 'Yapı Kredi', action: '+156M'),
        ],
      ),
    );
  }
}

class _RiskDisciplineCard extends StatelessWidget {
  const _RiskDisciplineCard();

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _CardTitle(icon: Icons.shield_rounded, title: 'Bugün Bunları Yapma'),
          SizedBox(height: 12),
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

  const _CardTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: BrokerColors.primary.withOpacity(.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: BrokerColors.primary.withOpacity(.18)),
          ),
          child: Icon(icon, color: BrokerColors.primary, size: 19),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(title, style: const TextStyle(color: BrokerColors.textMain, fontSize: 19, fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _MiniStat({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft.withOpacity(.66),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: BrokerColors.textSoft, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 15)),
        ],
      ),
    );
  }
}

class _MarketBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _MarketBox({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft.withOpacity(.66),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: BrokerColors.textSoft, fontWeight: FontWeight.w800, fontSize: 11)),
          const SizedBox(height: 7),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _MissionLine extends StatelessWidget {
  final String text;
  const _MissionLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: BrokerColors.primary.withOpacity(.12),
              shape: BoxShape.circle,
              border: Border.all(color: BrokerColors.primary.withOpacity(.22)),
            ),
            child: const Icon(Icons.check_rounded, color: BrokerColors.primary, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(child: InteractiveGlossaryText(text)),
        ],
      ),
    );
  }
}

class _OpportunityRow extends StatelessWidget {
  final String rank;
  final String symbol;
  final String note;
  final String score;
  const _OpportunityRow({required this.rank, required this.symbol, required this.note, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft.withOpacity(.66),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Row(
        children: [
          Text(rank, style: const TextStyle(color: BrokerColors.primary, fontWeight: FontWeight.w900)),
          const SizedBox(width: 11),
          Text(symbol, style: const TextStyle(color: BrokerColors.textMain, fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(width: 9),
          Expanded(child: Text(note, style: const TextStyle(color: BrokerColors.textSoft, fontWeight: FontWeight.w700))),
          Text(score, style: const TextStyle(color: BrokerColors.primary, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _InstitutionLine extends StatelessWidget {
  final String time;
  final String name;
  final String action;

  const _InstitutionLine({required this.time, required this.name, required this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(time, style: const TextStyle(color: BrokerColors.textMuted, fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(color: BrokerColors.textMain, fontWeight: FontWeight.w800))),
          Text(action, style: const TextStyle(color: BrokerColors.primary, fontWeight: FontWeight.w900)),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: BrokerColors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(child: InteractiveGlossaryText(text)),
        ],
      ),
    );
  }
}
