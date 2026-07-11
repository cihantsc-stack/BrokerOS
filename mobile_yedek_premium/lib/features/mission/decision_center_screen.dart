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
          _CrocHeader(),
          SizedBox(height: 20),
          _MarketHeroCard(),
          SizedBox(height: 16),
          _TodayMissionCard(),
          SizedBox(height: 16),
          _AiBriefCard(),
          SizedBox(height: 16),
          _MarketSnapshotGrid(),
          SizedBox(height: 16),
          _OpportunityListCard(),
          SizedBox(height: 16),
          _SmartMoneyCard(),
          SizedBox(height: 16),
          _InstitutionFlowCard(),
          SizedBox(height: 16),
          _RiskDisciplineCard(),
        ],
      ),
    );
  }
}

class _CrocHeader extends StatelessWidget {
  const _CrocHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: BrokerColors.crocGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: BrokerColors.primary.withOpacity(.24),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(Icons.flash_on_rounded, color: Colors.black, size: 32),
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
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'powered by Broker OS',
                    style: TextStyle(
                      color: BrokerColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'Grafiği değil, paranın izini sür.',
          style: TextStyle(
            color: BrokerColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Günaydın Cihan. Bugün piyasada 3 fırsat, 2 risk ve 1 kritik alarm var.',
          style: TextStyle(color: BrokerColors.textSoft, fontSize: 16, height: 1.4),
        ),
      ],
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
          const SizedBox(height: 14),
          const Text(
            'SEÇİCİ ALIM MODU',
            style: TextStyle(color: BrokerColors.primary, fontSize: 34, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          const InteractiveGlossaryText(
            'Piyasa genelinde Smart Money pozitif. Momentum güçlü ama Volatilite orta seviyede. Bu nedenle her hisse için ayrı Stop planı gerekli.',
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(child: _MiniStat(title: 'Güven', value: '%92', color: BrokerColors.green)),
              SizedBox(width: 10),
              Expanded(child: _MiniStat(title: 'Risk', value: 'Orta', color: BrokerColors.orange)),
              SizedBox(width: 10),
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
          SizedBox(height: 14),
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
          SizedBox(height: 14),
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
          const SizedBox(height: 14),
          Row(children: const [
            Expanded(child: _MarketBox(title: 'BIST100', value: '+1.82%', color: BrokerColors.green)),
            SizedBox(width: 10),
            Expanded(child: _MarketBox(title: 'DOLAR/TL', value: '-0.15%', color: BrokerColors.red)),
          ]),
          const SizedBox(height: 10),
          Row(children: const [
            Expanded(child: _MarketBox(title: 'GRAM ALTIN', value: '+0.65%', color: BrokerColors.green)),
            SizedBox(width: 10),
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
          SizedBox(height: 14),
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
          SizedBox(height: 14),
          Text('+1.24 Milyar TL', style: TextStyle(color: BrokerColors.primary, fontSize: 30, fontWeight: FontWeight.w900)),
          SizedBox(height: 8),
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
          _CardTitle(icon: Icons.timeline_rounded, title: 'Kurum Hareketleri'),
          SizedBox(height: 14),
          _FlowLine(time: '09:42', institution: 'İş Yatırım', symbol: 'ASELS', amount: '+48M'),
          _FlowLine(time: '10:05', institution: 'Yapı Kredi', symbol: 'THYAO', amount: '+31M'),
          _FlowLine(time: '10:18', institution: 'Ak Yatırım', symbol: 'AKBNK', amount: '+26M'),
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

  const _CardTitle({required this.icon, required this.title});

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
          child: Text(title, style: const TextStyle(color: BrokerColors.textMain, fontSize: 21, fontWeight: FontWeight.w900)),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: BrokerColors.textSoft, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: BrokerColors.textSoft, fontWeight: FontWeight.w800, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Row(
        children: [
          Text(rank, style: const TextStyle(color: BrokerColors.primary, fontWeight: FontWeight.w900)),
          const SizedBox(width: 12),
          Text(symbol, style: const TextStyle(color: BrokerColors.textMain, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(width: 10),
          Expanded(child: Text(note, style: const TextStyle(color: BrokerColors.textSoft, fontWeight: FontWeight.w700))),
          Text(score, style: const TextStyle(color: BrokerColors.primary, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _FlowLine extends StatelessWidget {
  final String time;
  final String institution;
  final String symbol;
  final String amount;

  const _FlowLine({required this.time, required this.institution, required this.symbol, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Row(
        children: [
          Text(time, style: const TextStyle(color: BrokerColors.textMuted, fontWeight: FontWeight.w800)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(institution, style: const TextStyle(color: BrokerColors.textMain, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(symbol, style: const TextStyle(color: BrokerColors.textSoft, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(color: BrokerColors.primary, fontWeight: FontWeight.w900, fontSize: 16)),
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
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: BrokerColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(child: InteractiveGlossaryText(text)),
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
          const Icon(Icons.warning_amber_rounded, color: BrokerColors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(child: InteractiveGlossaryText(text)),
        ],
      ),
    );
  }
}
