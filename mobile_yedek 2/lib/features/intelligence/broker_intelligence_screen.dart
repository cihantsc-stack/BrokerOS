import 'package:flutter/material.dart';

import '../../shared/widgets/broker_page.dart';
import '../../core/theme/croc_colors.dart';
import '../../widget/croc_card.dart';
import '../../widget/croc_badge.dart';
import '../../widget/croc_metric_tile.dart';
import '../../widget/croc_progress_bar.dart';
import '../../widget/croc_section_header.dart';
import '../../shared/glossary/interactive_glossary_text.dart';

class BrokerIntelligenceScreen extends StatelessWidget {
  final String symbol;

  const BrokerIntelligenceScreen({
    super.key,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CrocColors.background,
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
              style: const TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.w900,
                color: CrocColors.primary,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'CROC AI Zekâ Raporu',
              style: TextStyle(
                color: CrocColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Açıklanabilir karar merkezi • YTD',
              style: TextStyle(color: CrocColors.textSecondary),
            ),

            const SizedBox(height: 22),

            const _FinalDecisionHero(),
            const SizedBox(height: 18),

            const _PricePlanCard(),
            const SizedBox(height: 18),

            const _ConsensusCard(),
            const SizedBox(height: 18),

            const _AiNarrativeCard(),
            const SizedBox(height: 18),

            const _RiskCard(),
            const SizedBox(height: 18),

            const _GameTheoryCard(),
            const SizedBox(height: 18),

            const _ChangeMindCard(),
          ],
        ),
      ),
    );
  }
}

class _FinalDecisionHero extends StatelessWidget {
  const _FinalDecisionHero();

  @override
  Widget build(BuildContext context) {
    return CrocCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CrocSectionHeader(
            title: 'Broker Nihai Kararı',
            subtitle: 'Teknik, kurum, haber, risk ve para akışı birlikte okunur.',
            icon: Icons.psychology_alt_rounded,
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              CrocBadge(
                text: 'GÜÇLÜ AL',
                type: CrocBadgeType.buy,
                icon: Icons.trending_up_rounded,
              ),
              SizedBox(width: 10),
              CrocBadge(
                text: 'RİSK: ORTA',
                type: CrocBadgeType.risk,
                icon: Icons.warning_amber_rounded,
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            '94',
            style: TextStyle(
              color: CrocColors.primary,
              fontSize: 64,
              fontWeight: FontWeight.w900,
              height: .9,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Broker Consensus Skoru',
            style: TextStyle(
              color: CrocColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          const CrocProgressBar(value: .94, height: 12),
          const SizedBox(height: 18),
          const InteractiveGlossaryText(
            'Smart Money pozitif. Momentum güçlü. RSI ve MACD tarafında karar destekleniyor. Volatilite orta seviyede olduğu için Stop disiplini korunmalı.',
          ),
        ],
      ),
    );
  }
}

class _PricePlanCard extends StatelessWidget {
  const _PricePlanCard();

  @override
  Widget build(BuildContext context) {
    return CrocCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CrocSectionHeader(
            title: 'Giriş / Stop / Hedef',
            subtitle: 'İşlem planı net olmalı. Plansız işlem yok.',
            icon: Icons.track_changes_rounded,
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: CrocMetricTile(
                  title: 'Giriş',
                  value: '148.20',
                  icon: Icons.login_rounded,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: CrocMetricTile(
                  title: 'Stop',
                  value: '145.40',
                  icon: Icons.shield_rounded,
                  color: CrocColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(child: CrocMetricTile(title: 'Hedef 1', value: '154.80')),
              SizedBox(width: 10),
              Expanded(child: CrocMetricTile(title: 'Hedef 2', value: '160.20')),
            ],
          ),
          const SizedBox(height: 10),
          const CrocMetricTile(
            title: 'Hedef 3',
            value: '166.00',
            color: CrocColors.success,
          ),
        ],
      ),
    );
  }
}

class _ConsensusCard extends StatelessWidget {
  const _ConsensusCard();

  @override
  Widget build(BuildContext context) {
    return CrocCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          CrocSectionHeader(
            title: 'Broker Consensus',
            subtitle: 'Karar tek göstergeden değil, birleşik zekâdan çıkar.',
            icon: Icons.hub_rounded,
          ),
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

class _AiNarrativeCard extends StatelessWidget {
  const _AiNarrativeCard();

  @override
  Widget build(BuildContext context) {
    return CrocCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          CrocSectionHeader(
            title: 'CROC AI Yorumu',
            subtitle: 'Baş analist diliyle sade açıklama.',
            icon: Icons.smart_toy_rounded,
          ),
          SizedBox(height: 16),
          InteractiveGlossaryText(
            'Bu hissede Smart Money tarafı pozitif bölgede. Momentum güçlü kalıyor ve fiyat Destek üzerinde tutunuyor. Direnç bölgesine yaklaşırken Volatilite izlenmeli. MACD ve RSI kararı destekliyor ancak Stop seviyesi kırılırsa pozitif senaryo bozulur.',
          ),
        ],
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  const _RiskCard();

  @override
  Widget build(BuildContext context) {
    return CrocCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          CrocSectionHeader(
            title: 'Risk Motoru',
            subtitle: 'Pozitif senaryo hangi şartta bozulur?',
            icon: Icons.warning_amber_rounded,
          ),
          SizedBox(height: 16),
          InteractiveGlossaryText(
            'Volatilite orta seviyede. Stop seviyesi olan 145.40 altında günlük kapanış gelirse karar BEKLE seviyesine iner. Direnç bölgesinde hacim zayıflarsa işlem riski artar.',
          ),
        ],
      ),
    );
  }
}

class _GameTheoryCard extends StatelessWidget {
  const _GameTheoryCard();

  @override
  Widget build(BuildContext context) {
    return CrocCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          CrocSectionHeader(
            title: 'Oyun Teorisi',
            subtitle: 'Büyük oyuncu davranışı senaryo olarak okunur.',
            icon: Icons.auto_graph_rounded,
          ),
          SizedBox(height: 16),
          InteractiveGlossaryText(
            'Game Theory okumasına göre büyük oyuncu fiyatı yukarı taşımadan önce hacim biriktiriyor olabilir. Bu senaryoda Smart Money devam ederse 3-7 gün içinde yukarı hareket olasılığı artar.',
          ),
        ],
      ),
    );
  }
}

class _ChangeMindCard extends StatelessWidget {
  const _ChangeMindCard();

  @override
  Widget build(BuildContext context) {
    return CrocCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          CrocSectionHeader(
            title: 'Fikrim Ne Zaman Değişir?',
            subtitle: 'CROC AI kararını şartlara göre günceller.',
            icon: Icons.change_circle_rounded,
          ),
          SizedBox(height: 16),
          InteractiveGlossaryText(
            '145.40 altında günlük kapanış olursa Stop çalışır ve karar BEKLE seviyesine iner. Smart Money çıkışa dönerse, Momentum zayıflarsa veya RSI negatif bölgeye geçerse güçlü al senaryosu iptal edilir.',
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String title;
  final int value;

  const _ScoreRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final color = value >= 90
        ? CrocColors.success
        : value >= 75
            ? CrocColors.warning
            : CrocColors.danger;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: CrocColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$value',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          CrocProgressBar(
            value: value / 100,
            color: color,
          ),
        ],
      ),
    );
  }
}