import 'package:flutter/material.dart';

import '../../shared/design/broker_colors.dart';
import '../../shared/widgets/broker_card.dart';
import '../../shared/widgets/broker_page.dart';

import '../../widget/intelligence/live_market_header.dart';
import '../../widget/intelligence/global_risk_card.dart';
import '../../widget/intelligence/ai_mission_card.dart';
import '../../widget/intelligence/pressure_gauge_card.dart';
import '../../widget/intelligence/opportunity_scanner_card.dart';
import '../../widget/intelligence/broker_ai_comment_card.dart';
import '../../widget/intelligence/final_decision_card.dart';

class BrokerIntelligenceScreen extends StatelessWidget {
  final String symbol;

  const BrokerIntelligenceScreen({
    super.key,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

            const Text(
              '🦅 Broker Intelligence Report',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 18),

            Text(
              symbol,
              style: const TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.w900,
                color: BrokerColors.primary,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'AI destekli açıklanabilir hisse raporu',
              style: TextStyle(color: BrokerColors.textSoft),
            ),

            const SizedBox(height: 20),

            LiveMarketHeader(),
            const SizedBox(height: 18),

             GlobalRiskCard(),
            const SizedBox(height: 18),

            const _DecisionCard(),
            const SizedBox(height: 18),

            const _PriceCard(),
            const SizedBox(height: 18),

             AiMissionCard(),
            const SizedBox(height: 18),

             PressureGaugeCard(),
            const SizedBox(height: 18),

            OpportunityScannerCard(),
            const SizedBox(height: 18),

            const _WhyBuyCard(),
            const SizedBox(height: 18),

            const _WhyNotBuyCard(),
            const SizedBox(height: 18),

            const _ChangeMindCard(),
            const SizedBox(height: 18),

            const _DnaCard(),
            const SizedBox(height: 18),

            const _GameTheoryCard(),
            const SizedBox(height: 18),

             BrokerAiCommentCard(),
            const SizedBox(height: 18),

             FinalDecisionCard(),
          ],
        ),
      ),
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard();

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Broker Kararı',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 12),
          Text(
            'GÜÇLÜ AL',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: BrokerColors.primary,
            ),
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _Mini(title: 'AI Skoru', value: '94')),
              SizedBox(width: 10),
              Expanded(child: _Mini(title: 'Güven', value: '%92')),
              SizedBox(width: 10),
              Expanded(child: _Mini(title: 'Risk', value: 'Orta')),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard();

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giriş / Stop / Hedefler',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _Mini(title: 'Giriş', value: '148.20')),
              SizedBox(width: 10),
              Expanded(child: _Mini(title: 'Stop', value: '145.40')),
            ],
          ),
          SizedBox(height: 10),
          _TargetRow(title: 'Hedef 1', value: '154.80'),
          _TargetRow(title: 'Hedef 2', value: '160.20'),
          _TargetRow(title: 'Hedef 3', value: '166.00'),
        ],
      ),
    );
  }
}

class _WhyBuyCard extends StatelessWidget {
  const _WhyBuyCard();

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Neden Al?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 12),
          _CheckRow('Smart Money alımda'),
          _CheckRow('Savunma sektörü güçlü'),
          _CheckRow('MACD AL sinyali üretti'),
          _CheckRow('RSI yükseliş teyidinde'),
          _CheckRow('Kurumsal para girişi var'),
        ],
      ),
    );
  }
}

class _WhyNotBuyCard extends StatelessWidget {
  const _WhyNotBuyCard();

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Neden Almamalıyım?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 12),
          _WarningRow('Direnç bölgesine yakın'),
          _WarningRow('Volatilite artabilir'),
          _WarningRow('Makro veri riski var'),
        ],
      ),
    );
  }
}

class _ChangeMindCard extends StatelessWidget {
  const _ChangeMindCard();

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fikrim Ne Zaman Değişir?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 12),
          Text(
            '145.40 altında günlük kapanış olursa karar BEKLE seviyesine iner.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _DnaCard extends StatelessWidget {
  const _DnaCard();

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Broker DNA',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 14),
          _DnaRow(title: 'Teknik', value: 94),
          _DnaRow(title: 'Kurumsal', value: 96),
          _DnaRow(title: 'Para Akışı', value: 92),
          _DnaRow(title: 'Haber', value: 88),
          _DnaRow(title: 'Momentum', value: 95),
        ],
      ),
    );
  }
}

class _GameTheoryCard extends StatelessWidget {
  const _GameTheoryCard();

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Game Theory',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 12),
          Text(
            'Geçmiş benzer senaryolarda kurumsal alım devam ettiğinde 3-7 gün içinde yukarı hareket olasılığı artmıştır.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  final String title;
  final String value;

  const _Mini({
    required this.title,
    required this.value,
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

class _TargetRow extends StatelessWidget {
  final String title;
  final String value;

  const _TargetRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BrokerColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(
            value,
            style: const TextStyle(
              color: BrokerColors.green,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String text;

  const _CheckRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: BrokerColors.green),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
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
          const Icon(Icons.warning_rounded, color: BrokerColors.orange),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _DnaRow extends StatelessWidget {
  final String title;
  final int value;

  const _DnaRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final color = value >= 90
        ? BrokerColors.green
        : value >= 75
            ? BrokerColors.orange
            : BrokerColors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(title)),
              Text(
                '$value',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
              backgroundColor: BrokerColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}