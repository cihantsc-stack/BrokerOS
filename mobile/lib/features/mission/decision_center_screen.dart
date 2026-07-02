import 'package:flutter/material.dart';

import '../../shared/design/broker_colors.dart';
import '../../shared/widgets/broker_card.dart';
import '../../shared/widgets/broker_page.dart';

import '../decision_center/widgets/market_money_flow_card.dart';
import '../decision_center/widgets/morning_brief_card.dart';
import '../decision_center/widgets/news_impact_card.dart';
import '../decision_center/widgets/opportunity_card.dart';
import '../decision_center/widgets/pusu_score_card.dart';
import '../decision_center/widgets/sector_heatmap_card.dart';
import '../decision_center/widgets/smart_money_card.dart';

class DecisionCenterScreen extends StatelessWidget {
  const DecisionCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BrokerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _MissionHeader(),
          SizedBox(height: 18),
          _MarketDecisionCard(),
          SizedBox(height: 18),
          _TodayMissionCard(),
          SizedBox(height: 18),
          _DontDoTodayCard(),
          SizedBox(height: 18),
          _WhyCard(),
          SizedBox(height: 18),
          _ConfidenceCard(),

          SizedBox(height: 28),
          _SectionTitle('Detaylı Piyasa Analizi'),
          SizedBox(height: 18),

          MorningBriefCard(),
          SizedBox(height: 18),
          PusuScoreCard(),
          SizedBox(height: 18),
          MarketMoneyFlowCard(),
          SizedBox(height: 18),
          SectorHeatmapCard(),
          SizedBox(height: 18),
          OpportunityCard(),
          SizedBox(height: 18),
          SmartMoneyCard(),
          SizedBox(height: 18),
          NewsImpactCard(),
        ],
      ),
    );
  }
}

class _MissionHeader extends StatelessWidget {
  const _MissionHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🦅 Broker OS',
          style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 6),
        Text(
          'Grafiği değil, paranın izini sür.',
          style: TextStyle(
            color: BrokerColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 18),
        Text(
          'Günaydın Cihan. Bugün senin yerine piyasayı analiz ettim.',
          style: TextStyle(
            color: BrokerColors.textSoft,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _MarketDecisionCard extends StatelessWidget {
  const _MarketDecisionCard();

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bugünkü Piyasa Kararı',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 14),
          Text(
            'SEÇİCİ ALIM YAPILABİLİR',
            style: TextStyle(
              color: BrokerColors.primary,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Piyasa geneli pozitif. Ancak her hisse için ayrı karar verilmesi gerekiyor.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.4),
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  title: 'Güven',
                  value: '%92',
                  color: BrokerColors.green,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  title: 'Risk',
                  value: 'Orta',
                  color: BrokerColors.orange,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  title: 'Durum',
                  value: 'Pozitif',
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

class _TodayMissionCard extends StatelessWidget {
  const _TodayMissionCard();

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bugünün Görevi',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 14),
          _MissionRow(
            rank: '1',
            symbol: 'ASELS',
            text: 'Radarına al',
            score: '94',
          ),
          _MissionRow(
            rank: '2',
            symbol: 'THYAO',
            text: 'İzle',
            score: '89',
          ),
          _MissionRow(
            rank: '3',
            symbol: 'AK3',
            text: 'Fon tarafında takip et',
            score: '86',
          ),
        ],
      ),
    );
  }
}

class _DontDoTodayCard extends StatelessWidget {
  const _DontDoTodayCard();

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bugün Bunları Yapma',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 14),
          _WarningRow('Enerji sektöründe acele etme'),
          _WarningRow('Kaldıraçlı işlemde agresif olma'),
          _WarningRow('Panik satış yapma'),
        ],
      ),
    );
  }
}

class _WhyCard extends StatelessWidget {
  const _WhyCard();

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Neden Böyle Düşünüyor?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 14),
          _EvidenceRow(title: 'Smart Money', value: 5),
          _EvidenceRow(title: 'Kurumsal Para', value: 5),
          _EvidenceRow(title: 'Fon Girişi', value: 4),
          _EvidenceRow(title: 'RSI / MACD', value: 5),
          _EvidenceRow(title: 'Haber Akışı', value: 4),
        ],
      ),
    );
  }
}

class _ConfidenceCard extends StatelessWidget {
  const _ConfidenceCard();

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Broker Güven Endeksi',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 12),
          Text(
            '%92',
            style: TextStyle(
              fontSize: 54,
              fontWeight: FontWeight.w900,
              color: BrokerColors.primary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Bugünkü piyasa kararına yüksek güven var. Hisse bazlı kararlar Radar ve Intelligence ekranında ayrıca değerlendirilecek.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
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
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrokerColors.border),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  final String rank;
  final String symbol;
  final String text;
  final String score;

  const _MissionRow({
    required this.rank,
    required this.symbol,
    required this.text,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrokerColors.border),
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
            symbol,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: BrokerColors.textSoft),
            ),
          ),
          Text(
            score,
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

class _WarningRow extends StatelessWidget {
  final String text;

  const _WarningRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.close_rounded, color: BrokerColors.red),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _EvidenceRow extends StatelessWidget {
  final String title;
  final int value;

  const _EvidenceRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final stars = '★★★★★'.substring(0, value);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            stars,
            style: const TextStyle(color: BrokerColors.orange),
          ),
        ],
      ),
    );
  }
}