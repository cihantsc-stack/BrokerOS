import 'package:flutter/material.dart';

import '../../core/ai/council/broker_council_engine.dart';
import '../../core/ai/stock_decision_engine.dart';
import '../../core/engine/broker_engine.dart';
import '../../core/models/ai_decision.dart';
import '../../core/models/stock_analysis.dart';
import '../../shared/design/broker_colors.dart';
import '../../shared/glossary/interactive_glossary_text.dart';
import '../../shared/widgets/broker_card.dart';
import '../../shared/widgets/broker_page.dart';
import 'widgets/ai_confidence_card.dart';
import 'widgets/ai_mission_card.dart';
import 'widgets/ai_timeline_card.dart';
import 'widgets/ai_warning_card.dart';
import 'widgets/broker_council_card.dart';
import 'widgets/ai_morning_brief_card.dart';
import 'widgets/ai_decision_change_card.dart';
import 'widgets/ai_confidence_history_card.dart';
import 'widgets/ai_action_center_card.dart';
import 'widgets/ai_event_log_card.dart';
import 'widgets/ai_live_status_card.dart';
import 'widgets/ai_pulse_card.dart';

class BrokerIntelligenceScreen extends StatelessWidget {
  final String symbol;

  const BrokerIntelligenceScreen({
    super.key,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    final analyses = BrokerEngine.run();
    final stock = analyses.firstWhere(
      (item) => item.symbol == symbol,
      orElse: () => analyses.first,
    );
    final aiDecision = StockDecisionEngine.analyze(stock);
    final council = BrokerCouncilEngine.evaluate(stock);

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
              style: TextButton.styleFrom(
                foregroundColor: BrokerColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            _TopIdentity(stock: stock),
            const SizedBox(height: 18),
            BrokerCouncilCard(result: council),
            const SizedBox(height: 16),
            AiLiveStatusCard(stock: stock, decision: aiDecision),
            const SizedBox(height: 16),
            AiPulseCard(stock: stock, decision: aiDecision),
            const SizedBox(height: 16),
            AiActionCenterCard(stock: stock, decision: aiDecision),
            const SizedBox(height: 16),
            AiEventLogCard(stock: stock, decision: aiDecision),
            const SizedBox(height: 16),
            AiMorningBriefCard(stock: stock, decision: aiDecision),
            const SizedBox(height: 16),
            AiDecisionChangeCard(stock: stock, decision: aiDecision),
            const SizedBox(height: 16),
            AiConfidenceHistoryCard(decision: aiDecision),
            const SizedBox(height: 16),
            AiConfidenceCard(decision: aiDecision),
            const SizedBox(height: 16),
            AiMissionCard(decision: aiDecision),
            const SizedBox(height: 16),
            AiTimelineCard(timeline: aiDecision.timeline),
            const SizedBox(height: 16),
            AiWarningCard(decision: aiDecision),
            const SizedBox(height: 16),
            _DecisionHero(stock: stock),
            const SizedBox(height: 16),
            _LiveChartCard(stock: stock),
            const SizedBox(height: 16),
            _TradePlanCard(stock: stock),
            const SizedBox(height: 16),
            _ConsensusCard(stock: stock),
            const SizedBox(height: 16),
            _SmartMoneyCard(stock: stock),
            const SizedBox(height: 16),
            _AiReasoningCard(stock: stock),
            const SizedBox(height: 16),
            _RiskCard(stock: stock),
            const SizedBox(height: 16),
            _ChangeMindCard(stock: stock),
          ],
        ),
      ),
    );
  }
}

class _TopIdentity extends StatelessWidget {
  final StockAnalysis stock;

  const _TopIdentity({required this.stock});

  @override
  Widget build(BuildContext context) {
    final change = stock.dailyChange ?? 0;
    final changeColor = change >= 0 ? BrokerColors.green : BrokerColors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stock.symbol,
          style: const TextStyle(
            color: BrokerColors.primary,
            fontSize: 54,
            fontWeight: FontWeight.w900,
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
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: changeColor.withOpacity(.14),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: changeColor.withOpacity(.22)),
              ),
              child: Text(
                '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: changeColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          stock.company,
          style: const TextStyle(
            color: BrokerColors.textSoft,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'CROC AI Zekâ Raporu',
          style: TextStyle(
            color: BrokerColors.textMain,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Açıklanabilir karar merkezi • YTD',
          style: TextStyle(color: BrokerColors.textSoft),
        ),
      ],
    );
  }
}

class _DecisionHero extends StatelessWidget {
  final StockAnalysis stock;

  const _DecisionHero({required this.stock});

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.psychology_alt_rounded,
            title: 'Broker Nihai Kararı',
            subtitle: 'Teknik, kurum, haber, risk ve para akışı birlikte okunur.',
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _Pill(
                text: stock.decision,
                color: stock.decision.contains('AL')
                    ? BrokerColors.green
                    : BrokerColors.orange,
                icon: Icons.trending_up_rounded,
              ),
              const SizedBox(width: 10),
              _Pill(
                text: 'RİSK: ${stock.risk.toUpperCase()}',
                color: stock.risk == 'Orta'
                    ? BrokerColors.orange
                    : BrokerColors.green,
                icon: Icons.warning_amber_rounded,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _ScoreRing(score: stock.brokerConsensus),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stock.brokerConsensus}/100',
                      style: const TextStyle(
                        color: BrokerColors.primary,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Broker Consensus',
                      style: TextStyle(
                        color: BrokerColors.textSoft,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Progress(
                      value: stock.brokerConsensus / 100,
                      color: BrokerColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          InteractiveGlossaryText(
            '${stock.symbol} için Smart Money pozitif. Momentum güçlü. RSI ve MACD karar tarafını destekliyor. Volatilite orta seviyede olduğu için Stop disiplini korunmalı.',
          ),
        ],
      ),
    );
  }
}

class _LiveChartCard extends StatelessWidget {
  final StockAnalysis stock;

  const _LiveChartCard({required this.stock});

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.show_chart_rounded,
            title: 'Mini Fiyat Grafiği',
            subtitle: 'Kısa vadeli yön ve momentum görünümü.',
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: CustomPaint(
              painter: _ChartPainter(up: (stock.dailyChange ?? 0) >= 0),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TradePlanCard extends StatelessWidget {
  final StockAnalysis stock;

  const _TradePlanCard({required this.stock});

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.track_changes_rounded,
            title: 'Giriş / Stop / Hedef',
            subtitle: 'Plansız işlem yok. Önce risk, sonra kazanç.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  title: 'Giriş',
                  value: stock.entry.toStringAsFixed(2),
                  color: BrokerColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Metric(
                  title: 'Stop',
                  value: stock.stop.toStringAsFixed(2),
                  color: BrokerColors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  title: 'Hedef 1',
                  value: stock.target1.toStringAsFixed(2),
                  color: BrokerColors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Metric(
                  title: 'Hedef 2',
                  value: stock.target2.toStringAsFixed(2),
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

class _ConsensusCard extends StatelessWidget {
  final StockAnalysis stock;

  const _ConsensusCard({required this.stock});

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.hub_rounded,
            title: 'Broker Consensus',
            subtitle: 'Karar tek göstergeden değil, birleşik zekâdan çıkar.',
          ),
          const SizedBox(height: 16),
          _ScoreRow(title: 'Teknik Analiz', value: stock.technicalScore),
          _ScoreRow(title: 'Smart Money', value: stock.smartMoneyScore),
          _ScoreRow(title: 'Kurumsal Hareket', value: stock.institutionalScore),
          _ScoreRow(title: 'Haber Etkisi', value: stock.newsScore),
          _ScoreRow(title: 'Risk Kalitesi', value: stock.riskScore),
          _ScoreRow(title: 'Momentum', value: stock.momentumScore),
        ],
      ),
    );
  }
}

class _SmartMoneyCard extends StatelessWidget {
  final StockAnalysis stock;

  const _SmartMoneyCard({required this.stock});

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

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.account_balance_rounded,
            title: 'Smart Money & Kurumlar',
            subtitle: 'Büyük para hareketi ve ilk 3 kurum.',
          ),
          const SizedBox(height: 16),
          Text(
            _money(stock.smartMoneyFlow),
            style: const TextStyle(
              color: BrokerColors.primary,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Son 60 dakika kurumsal para akışı',
            style: TextStyle(color: BrokerColors.textSoft),
          ),
          const SizedBox(height: 16),
          _InstitutionRow(rank: '1', name: stock.firstInstitution ?? '-'),
          _InstitutionRow(rank: '2', name: stock.secondInstitution ?? '-'),
          _InstitutionRow(rank: '3', name: stock.thirdInstitution ?? '-'),
        ],
      ),
    );
  }
}

class _AiReasoningCard extends StatelessWidget {
  final StockAnalysis stock;

  const _AiReasoningCard({required this.stock});

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.smart_toy_rounded,
            title: 'CROC AI Yorumu',
            subtitle: 'Baş analist diliyle sade açıklama.',
          ),
          const SizedBox(height: 16),
          InteractiveGlossaryText(
            'Bugün ${stock.symbol} tarafında iyimserim. Sebep yalnızca teknik görünüm değil. Smart Money akışı pozitif, Momentum güçlü ve fiyat Destek üzerinde tutunuyor. Direnç bölgesine yaklaşırken hacim izlenmeli.',
          ),
        ],
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  final StockAnalysis stock;

  const _RiskCard({required this.stock});

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.warning_amber_rounded,
            title: 'Risk Motoru',
            subtitle: 'Pozitif senaryo hangi şartta bozulur?',
          ),
          const SizedBox(height: 16),
          InteractiveGlossaryText(
            'Volatilite orta seviyede. Stop seviyesi olan ${stock.stop.toStringAsFixed(2)} altında günlük kapanış gelirse karar BEKLE seviyesine iner. Direnç bölgesinde hacim zayıflarsa işlem riski artar.',
          ),
        ],
      ),
    );
  }
}

class _ChangeMindCard extends StatelessWidget {
  final StockAnalysis stock;

  const _ChangeMindCard({required this.stock});

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.change_circle_rounded,
            title: 'Fikrim Ne Zaman Değişir?',
            subtitle: 'CROC AI kararını şartlara göre günceller.',
          ),
          const SizedBox(height: 16),
          InteractiveGlossaryText(
            '${stock.stop.toStringAsFixed(2)} altında günlük kapanış olursa Stop çalışır ve karar BEKLE seviyesine iner. Smart Money çıkışa dönerse veya Momentum zayıflarsa güçlü al senaryosu iptal edilir.',
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  )),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    height: 1.3,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreRing extends StatelessWidget {
  final int score;

  const _ScoreRing({required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      height: 86,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 7,
            backgroundColor: BrokerColors.borderSoft,
            valueColor: const AlwaysStoppedAnimation<Color>(
              BrokerColors.primary,
            ),
          ),
          Text(
            '$score',
            style: const TextStyle(
              color: BrokerColors.primary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final bool up;

  _ChartPainter({required this.up});

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = BrokerColors.borderSoft.withOpacity(.45)
      ..strokeWidth = 1;

    for (int i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final points = [
      Offset(0, size.height * .72),
      Offset(size.width * .15, size.height * .62),
      Offset(size.width * .30, size.height * .66),
      Offset(size.width * .45, size.height * .44),
      Offset(size.width * .60, size.height * .52),
      Offset(size.width * .75, size.height * .30),
      Offset(size.width * .90, size.height * .34),
      Offset(size.width, size.height * .18),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }

    final glow = Paint()
      ..color = BrokerColors.primary.withOpacity(.22)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final line = Paint()
      ..color = BrokerColors.primary
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, glow);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const _Pill({
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  final double value;
  final Color color;

  const _Progress({
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 10,
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

  const _Metric({
    required this.title,
    required this.value,
    required this.color,
  });

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                color: BrokerColors.textSoft,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              )),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                color: color,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              )),
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
    final color =
        value >= 90 ? BrokerColors.green : value >= 75 ? BrokerColors.orange : BrokerColors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                      color: BrokerColors.textMain,
                      fontWeight: FontWeight.w800,
                    )),
              ),
              Text('$value',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  )),
            ],
          ),
          const SizedBox(height: 7),
          _Progress(value: value / 100, color: color),
        ],
      ),
    );
  }
}

class _InstitutionRow extends StatelessWidget {
  final String rank;
  final String name;

  const _InstitutionRow({
    required this.rank,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: BrokerColors.primary.withOpacity(.12),
              shape: BoxShape.circle,
              border: Border.all(color: BrokerColors.primary.withOpacity(.24)),
            ),
            child: Text(
              rank,
              style: const TextStyle(
                color: BrokerColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: BrokerColors.textMain,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}