import 'package:flutter/material.dart';

import '../../shared/design/broker_colors.dart';
import '../../shared/glossary/interactive_glossary_text.dart';
import '../../shared/widgets/broker_card.dart';
import '../../shared/widgets/broker_page.dart';

class BrokerIntelligenceScreen extends StatelessWidget {
  final String symbol;

  const BrokerIntelligenceScreen({
    super.key,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrokerColors.background,
      body: BrokerPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Geri'),
            ),
            const SizedBox(height: 12),
            Text(
              symbol,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: BrokerColors.primary),
            ),
            const SizedBox(height: 6),
            const Text(
              'CROC AI Zekâ Raporu',
              style: TextStyle(color: BrokerColors.textMain, fontSize: 30, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text('Açıklanabilir karar merkezi • YTD', style: TextStyle(color: BrokerColors.textSoft)),
            const SizedBox(height: 22),
            const _DecisionHero(),
            SizedBox(height: 16),
            const _AiReasoningCard(),
            SizedBox(height: 16),
            const _TradePlanCard(),
            SizedBox(height: 16),
            const _ConsensusCard(),
            SizedBox(height: 16),
            const _RiskCard(),
            SizedBox(height: 16),
            const _GameTheoryCard(),
            SizedBox(height: 16),
            const _ChangeMindCard(),
          ],
        ),
      ),
    );
  }
}

class _DecisionHero extends StatelessWidget {
  const _DecisionHero();

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionHeader(icon: Icons.psychology_alt_rounded, title: 'Broker Nihai Kararı', subtitle: 'Teknik, kurum, haber, risk ve para akışı birlikte okunur.'),
          SizedBox(height: 18),
          Row(children: [
            _Pill(text: 'GÜÇLÜ AL', color: BrokerColors.green, icon: Icons.trending_up_rounded),
            SizedBox(width: 10),
            _Pill(text: 'RİSK: ORTA', color: BrokerColors.orange, icon: Icons.warning_amber_rounded),
          ]),
          SizedBox(height: 20),
          Text('94', style: TextStyle(color: BrokerColors.primary, fontSize: 70, fontWeight: FontWeight.w900, height: .9)),
          SizedBox(height: 6),
          Text('Broker Consensus Skoru', style: TextStyle(color: BrokerColors.textSoft, fontWeight: FontWeight.w800)),
          SizedBox(height: 18),
          _Progress(value: .94, color: BrokerColors.primary),
          SizedBox(height: 18),
          InteractiveGlossaryText('Smart Money pozitif. Momentum güçlü. RSI ve MACD tarafında karar destekleniyor. Volatilite orta seviyede olduğu için Stop disiplini korunmalı.'),
        ],
      ),
    );
  }
}

class _AiReasoningCard extends StatelessWidget {
  const _AiReasoningCard();

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionHeader(icon: Icons.smart_toy_rounded, title: 'CROC AI Yorumu', subtitle: 'Baş analist diliyle sade açıklama.'),
          SizedBox(height: 16),
          InteractiveGlossaryText('Bugün bu hissede iyimserim. Sebep yalnızca teknik görünüm değil. Smart Money akışı pozitif, Momentum güçlü ve fiyat Destek üzerinde tutunuyor. Direnç bölgesine yaklaşırken hacim izlenmeli.'),
        ],
      ),
    );
  }
}

class _TradePlanCard extends StatelessWidget {
  const _TradePlanCard();

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(icon: Icons.track_changes_rounded, title: 'Giriş / Stop / Hedef', subtitle: 'Plansız işlem yok. Önce risk, sonra kazanç.'),
          const SizedBox(height: 16),
          Row(children: const [
            Expanded(child: _Metric(title: 'Giriş', value: '148.20', color: BrokerColors.primary)),
            SizedBox(width: 10),
            Expanded(child: _Metric(title: 'Stop', value: '145.40', color: BrokerColors.orange)),
          ]),
          const SizedBox(height: 10),
          Row(children: const [
            Expanded(child: _Metric(title: 'Hedef 1', value: '154.80', color: BrokerColors.green)),
            SizedBox(width: 10),
            Expanded(child: _Metric(title: 'Hedef 2', value: '160.20', color: BrokerColors.green)),
          ]),
          const SizedBox(height: 10),
          const _Metric(title: 'Hedef 3', value: '166.00', color: BrokerColors.green),
        ],
      ),
    );
  }
}

class _ConsensusCard extends StatelessWidget {
  const _ConsensusCard();

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionHeader(icon: Icons.hub_rounded, title: 'Broker Consensus', subtitle: 'Karar tek göstergeden değil, birleşik zekâdan çıkar.'),
          SizedBox(height: 16),
          _ScoreRow(title: 'Teknik Analiz', value: 94),
          _ScoreRow(title: 'Kurumsal Hareket', value: 96),
          _ScoreRow(title: 'Para Akışı', value: 92),
          _ScoreRow(title: 'Haber Etkisi', value: 84),
          _ScoreRow(title: 'Momentum', value: 95),
        ],
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  const _RiskCard();

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionHeader(icon: Icons.warning_amber_rounded, title: 'Risk Motoru', subtitle: 'Pozitif senaryo hangi şartta bozulur?'),
          SizedBox(height: 16),
          InteractiveGlossaryText('Volatilite orta seviyede. Stop seviyesi olan 145.40 altında günlük kapanış gelirse karar BEKLE seviyesine iner. Direnç bölgesinde hacim zayıflarsa işlem riski artar.'),
        ],
      ),
    );
  }
}

class _GameTheoryCard extends StatelessWidget {
  const _GameTheoryCard();

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionHeader(icon: Icons.auto_graph_rounded, title: 'Oyun Teorisi', subtitle: 'Büyük oyuncu davranışı senaryo olarak okunur.'),
          SizedBox(height: 16),
          InteractiveGlossaryText('Game Theory okumasına göre büyük oyuncu fiyatı yukarı taşımadan önce hacim biriktiriyor olabilir. Smart Money devam ederse 3-7 gün içinde yukarı hareket olasılığı artar.'),
        ],
      ),
    );
  }
}

class _ChangeMindCard extends StatelessWidget {
  const _ChangeMindCard();

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionHeader(icon: Icons.change_circle_rounded, title: 'Fikrim Ne Zaman Değişir?', subtitle: 'CROC AI kararını şartlara göre günceller.'),
          SizedBox(height: 16),
          InteractiveGlossaryText('145.40 altında günlük kapanış olursa Stop çalışır ve karar BEKLE seviyesine iner. Smart Money çıkışa dönerse, Momentum zayıflarsa veya RSI negatif bölgeye geçerse güçlü al senaryosu iptal edilir.'),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SectionHeader({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: BrokerColors.primary.withOpacity(.10),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: BrokerColors.primary.withOpacity(.18)),
        ),
        child: Icon(icon, color: BrokerColors.primary, size: 22),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: BrokerColors.textMain, fontSize: 21, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: BrokerColors.textSoft, height: 1.3)),
      ])),
    ]);
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  const _Pill({required this.text, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900)),
      ]),
    );
  }
}

class _Progress extends StatelessWidget {
  final double value;
  final Color color;
  const _Progress({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 11,
        backgroundColor: BrokerColors.borderSoft,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _Metric({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: BrokerColors.textSoft, fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
      ]),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String title;
  final int value;
  const _ScoreRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final color = value >= 90 ? BrokerColors.green : value >= 75 ? BrokerColors.orange : BrokerColors.red;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(children: [
        Row(children: [
          Expanded(child: Text(title, style: const TextStyle(color: BrokerColors.textMain, fontWeight: FontWeight.w800))),
          Text('$value', style: TextStyle(color: color, fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 7),
        _Progress(value: value / 100, color: color),
      ]),
    );
  }
}
