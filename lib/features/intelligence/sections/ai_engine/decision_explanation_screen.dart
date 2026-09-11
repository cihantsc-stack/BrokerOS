import 'package:flutter/material.dart';

import '../../../../core/models/stock_analysis.dart';
import '../../../../shared/design/broker_colors.dart';
import '../../../../shared/widgets/broker_card.dart';
import '../../../../shared/widgets/broker_page.dart';

class DecisionExplanationScreen extends StatelessWidget {
  final StockAnalysis stock;
  final dynamic decision;

  const DecisionExplanationScreen({
    super.key,
    required this.stock,
    required this.decision,
  });

  @override
  Widget build(BuildContext context) {
    final decisionText = decision.decision.toString();
    // V31: Guven de CrocDecisionResult tarafindan belirlenir.
    final confidence = _score(decision.confidence, 0);
    final signals = <_SignalData>[
      _SignalData(
        'Teknik yapı',
        stock.technicalScore,
        Icons.show_chart_rounded,
      ),
      _SignalData('Momentum', stock.momentumScore, Icons.speed_rounded),
      _SignalData(
        'Kurumsal para',
        stock.institutionalScore,
        Icons.account_balance_rounded,
      ),
      _SignalData('Smart Money', stock.smartMoneyScore, Icons.radar_rounded),
      _SignalData('Haber etkisi', stock.newsScore, Icons.newspaper_rounded),
      _SignalData(
        'Risk dengesi',
        100 - stock.riskScore,
        Icons.health_and_safety_rounded,
      ),
      _SignalData('Genel konsensüs', confidence, Icons.hub_rounded),
    ];

    final approved = signals.where((item) => item.score >= 55).length;
    final positive = decisionText.toUpperCase().contains('AL');
    final tone = positive ? BrokerColors.green : BrokerColors.orange;

    return Scaffold(
      backgroundColor: BrokerColors.background,
      body: BrokerPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Analize dön'),
              style: TextButton.styleFrom(
                foregroundColor: BrokerColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${stock.symbol} • Karar Açıklaması',
              style: const TextStyle(
                color: BrokerColors.textMain,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'CROC AI kararının hangi sinyallerden oluştuğunu adım adım gösterir.',
              style: TextStyle(color: BrokerColors.textSoft, height: 1.45),
            ),
            const SizedBox(height: 18),
            BrokerCard(
              glow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: tone.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(Icons.psychology_alt_rounded, color: tone),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              decisionText,
                              style: TextStyle(
                                color: tone,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '$approved / ${signals.length} sinyal onayı',
                              style: const TextStyle(
                                color: BrokerColors.textSoft,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '%$confidence',
                        style: TextStyle(
                          color: tone,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: confidence / 100,
                      minHeight: 10,
                      backgroundColor: BrokerColors.textSoft.withValues(
                        alpha: 0.12,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(tone),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BrokerCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    icon: Icons.account_tree_rounded,
                    title: 'Karar nasıl oluştu?',
                    subtitle:
                        'Her sinyal nihai karara farklı ağırlıkla katkı sağlar.',
                  ),
                  const SizedBox(height: 16),
                  for (var i = 0; i < signals.length; i++) ...[
                    _SignalStep(index: i + 1, data: signals[i]),
                    if (i != signals.length - 1) const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            BrokerCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    icon: Icons.auto_awesome_rounded,
                    title: 'CROC AI yorumu',
                    subtitle:
                        'Skorların birlikte okunmasından çıkan sade sonuç.',
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _comment(
                      stock: stock,
                      decisionText: decisionText,
                      approved: approved,
                    ),
                    style: const TextStyle(
                      color: BrokerColors.textMain,
                      height: 1.55,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BrokerCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    icon: Icons.rule_rounded,
                    title: 'Kararın geçerlilik şartları',
                    subtitle:
                        'Bu koşullar bozulursa karar yeniden hesaplanmalıdır.',
                  ),
                  const SizedBox(height: 14),
                  _Rule(
                    text:
                        '${stock.stop.toStringAsFixed(2)} ₺ stop seviyesinin altında kalıcılık oluşmamalı.',
                  ),
                  const SizedBox(height: 10),
                  const _Rule(
                    text: 'Kurumsal para akışı belirgin satışa dönmemeli.',
                  ),
                  const SizedBox(height: 10),
                  const _Rule(
                    text: 'Smart Money ve momentum aynı anda zayıflamamalı.',
                  ),
                  const SizedBox(height: 10),
                  const _Rule(text: 'Endeks riski sert biçimde yükselmemeli.'),
                ],
              ),
            ),
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }

  static int _score(dynamic value, int fallback) {
    if (value is int) return value.clamp(0, 100);
    if (value is double) return value.round().clamp(0, 100);
    return int.tryParse(value.toString())?.clamp(0, 100) ?? fallback;
  }

  static String _comment({
    required StockAnalysis stock,
    required String decisionText,
    required int approved,
  }) {
    final strongest = <(String, int)>[
      ('teknik yapı', stock.technicalScore),
      ('momentum', stock.momentumScore),
      ('kurumsal para', stock.institutionalScore),
      ('Smart Money', stock.smartMoneyScore),
      ('haber akışı', stock.newsScore),
    ]..sort((a, b) => b.$2.compareTo(a.$2));

    final first = strongest[0].$1;
    final second = strongest[1].$1;
    final riskText = stock.riskScore >= 60
        ? 'Risk skoru yüksek olduğu için pozisyon büyüklüğü kontrollü tutulmalı.'
        : 'Risk dengesi kararın uygulanmasına engel oluşturmuyor.';

    return '${stock.symbol} için $decisionText kararı verildi. '
        'En güçlü destek $first ve $second tarafında. '
        '$approved ana sinyal kararı doğruluyor. $riskText';
  }
}

class _SignalData {
  final String title;
  final int score;
  final IconData icon;

  bool get hasData => score > 0;

  const _SignalData(this.title, this.score, this.icon);
}

class _SignalStep extends StatelessWidget {
  final int index;
  final _SignalData data;

  const _SignalStep({required this.index, required this.data});

  @override
  Widget build(BuildContext context) {
    final hasData = data.hasData;
    final approved = hasData && data.score >= 55;

    final tone = !hasData
        ? BrokerColors.textSoft
        : approved
        ? BrokerColors.green
        : BrokerColors.red;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: TextStyle(color: tone, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 11),
          Icon(data.icon, color: tone, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              data.title,
              style: const TextStyle(
                color: BrokerColors.textMain,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${data.score}',
                style: TextStyle(
                  color: tone,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                !hasData
                    ? 'VERİ BEKLENİYOR'
                    : approved
                    ? 'ONAY'
                    : 'ZAYIF',
                style: TextStyle(
                  color: tone,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: BrokerColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: BrokerColors.textMain,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: BrokerColors.textSoft,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Rule extends StatelessWidget {
  final String text;

  const _Rule({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          color: BrokerColors.orange,
          size: 20,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: BrokerColors.textMain,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
