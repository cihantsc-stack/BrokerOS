import 'package:flutter/material.dart';

import '../../../../core/models/stock_analysis.dart';
import '../../../../shared/design/broker_colors.dart';
import '../../../../shared/widgets/broker_card.dart';
import 'decision_explanation_screen.dart';

class CrocAiEngineSection extends StatelessWidget {
  final StockAnalysis stock;
  final dynamic decision;

  const CrocAiEngineSection({
    super.key,
    required this.stock,
    required this.decision,
  });

  @override
  Widget build(BuildContext context) {
    // V31: Ekrandaki nihai karar ve guven icin TEK OTORITE CrocDecisionResult.
    final int confidence = CrocAiEngineSection._asInt(
      decision.confidence,
      fallback: 0,
    );
    final String decisionText = decision.decision.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CrocVoiceCard(
          stock: stock,
          decisionText: decisionText,
          confidence: confidence,
        ),
        const SizedBox(height: 14),
        _ReasoningFlowCard(
          stock: stock,
          decisionText: decisionText,
          confidence: confidence,
        ),
        const SizedBox(height: 14),
        _ConfidenceThermometer(confidence: confidence),
        const SizedBox(height: 14),
        _ConsensusMatrix(stock: stock, finalConsensus: confidence),
        const SizedBox(height: 14),
        _WhyCard(stock: stock, decisionText: decisionText),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DecisionExplanationScreen(
                    stock: stock,
                    decision: decision,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.account_tree_rounded),
            label: const Text('Neden bu kararı verdi?'),
            style: FilledButton.styleFrom(
              backgroundColor: BrokerColors.primary,
              foregroundColor: BrokerColors.background,
              padding: const EdgeInsets.symmetric(vertical: 15),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _InvalidationCard(stock: stock),
      ],
    );
  }

  static int _asInt(dynamic value, {required int fallback}) {
    if (value is int) return value.clamp(0, 100);
    if (value is double) return value.round().clamp(0, 100);
    return int.tryParse(value.toString())?.clamp(0, 100) ?? fallback;
  }
}

class _CrocVoiceCard extends StatelessWidget {
  final StockAnalysis stock;
  final String decisionText;
  final int confidence;

  const _CrocVoiceCard({
    required this.stock,
    required this.decisionText,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = decisionText.toUpperCase().contains('AL');
    final tone = isPositive ? BrokerColors.green : BrokerColors.orange;

    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: BrokerColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.record_voice_over_rounded,
                  color: BrokerColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CROC AI Konuşuyor',
                      style: TextStyle(
                        color: BrokerColors.textMain,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Canlı karar özeti',
                      style: TextStyle(color: BrokerColors.textSoft),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '%$confidence',
                  style: TextStyle(color: tone, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${stock.symbol} için kararım: $decisionText. '
            'Teknik görünüm, para akışı ve risk dengesi birlikte değerlendirildi. '
            '${isPositive ? 'Alım tarafı güçlü; ancak stop disiplini korunmalı.' : 'Yeni işlem için teyit beklemek daha doğru.'}',
            style: const TextStyle(
              color: BrokerColors.textMain,
              height: 1.55,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasoningFlowCard extends StatelessWidget {
  final StockAnalysis stock;
  final String decisionText;
  final int confidence;

  const _ReasoningFlowCard({
    required this.stock,
    required this.decisionText,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Teknik analiz incelendi', stock.technicalScore),
      ('Kurumsal para akışı incelendi', stock.institutionalScore),
      ('Haber etkisi hesaplandı', stock.newsScore),
      (
        'Risk analizi tamamlandı',
        stock.riskScore == 0 ? 0 : 100 - stock.riskScore,
      ),
      ('Smart Money doğrulandı', stock.smartMoneyScore),
    ];

    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(
            icon: Icons.psychology_alt_rounded,
            title: 'CROC AI Analiz Akışı',
            subtitle: 'Kararın hangi kontrol adımlarından geçtiğini gösterir.',
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < steps.length; i++) ...[
            _ReasoningStep(
              index: i + 1,
              label: steps[i].$1,
              score: steps[i].$2,
            ),
            if (i != steps.length - 1) const SizedBox(height: 9),
          ],
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: BrokerColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: BrokerColors.primary.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.flag_rounded, color: BrokerColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Nihai sonuç: $decisionText • Güven %$confidence',
                    style: const TextStyle(
                      color: BrokerColors.textMain,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasoningStep extends StatelessWidget {
  final int index;
  final String label;
  final int score;

  const _ReasoningStep({
    required this.index,
    required this.label,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final available = score > 0;
    final passed = available && score >= 55;
    final tone = !available
        ? BrokerColors.textSoft
        : passed
        ? BrokerColors.green
        : BrokerColors.orange;

    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: passed
              ? Icon(Icons.check_rounded, size: 18, color: tone)
              : Text(
                  '$index',
                  style: TextStyle(color: tone, fontWeight: FontWeight.w900),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          available ? '$score/100' : 'VERİ BEKLENİYOR',
          style: TextStyle(color: tone, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _ConfidenceThermometer extends StatelessWidget {
  final int confidence;

  const _ConfidenceThermometer({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final tone = confidence >= 80
        ? BrokerColors.green
        : confidence >= 60
        ? BrokerColors.orange
        : BrokerColors.red;
    final label = confidence >= 85
        ? 'Çok Güvenilir'
        : confidence >= 70
        ? 'Güvenilir'
        : confidence >= 55
        ? 'Teyit Gerekli'
        : 'Düşük Güven';

    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(
            icon: Icons.thermostat_rounded,
            title: 'AI Güven Termometresi',
            subtitle: 'Verilerin birbirini ne ölçüde doğruladığını gösterir.',
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '%$confidence',
                style: TextStyle(
                  color: tone,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  label,
                  style: TextStyle(color: tone, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: confidence / 100,
              minHeight: 12,
              backgroundColor: BrokerColors.textSoft.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(tone),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsensusMatrix extends StatelessWidget {
  final StockAnalysis stock;
  final int finalConsensus;

  const _ConsensusMatrix({required this.stock, required this.finalConsensus});

  @override
  Widget build(BuildContext context) {
    final checks = <(String, int)>[
      ('Teknik', stock.technicalScore),
      ('Momentum', stock.momentumScore),
      ('Kurumsal', stock.institutionalScore),
      ('Smart Money', stock.smartMoneyScore),
      ('Haber', stock.newsScore),
      ('Risk Dengesi', stock.riskScore == 0 ? 0 : 100 - stock.riskScore),
      ('Genel Konsensüs', finalConsensus),
    ];
    final active = checks.where((item) => item.$2 > 0).toList();
    final approved = active.where((item) => item.$2 >= 55).length;
    final waiting = checks.length - active.length;

    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(
            icon: Icons.hub_rounded,
            title: 'Broker Consensus 2.0',
            subtitle: 'Yedi ana sinyalin ortak karar tablosu.',
          ),
          const SizedBox(height: 14),
          for (final item in checks) ...[
            _ConsensusRow(label: item.$1, score: item.$2),
            const SizedBox(height: 8),
          ],
          const Divider(height: 22),
          Text(
            '$approved / ${active.length} aktif sinyal onay • $waiting kaynak bekleniyor',
            style: const TextStyle(
              color: BrokerColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsensusRow extends StatelessWidget {
  final String label;
  final int score;

  const _ConsensusRow({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    final available = score > 0;
    final approved = available && score >= 55;

    final tone = !available
        ? BrokerColors.textSoft
        : approved
        ? BrokerColors.green
        : BrokerColors.red;

    return Row(
      children: [
        Icon(
          !available
              ? Icons.hourglass_top_rounded
              : approved
              ? Icons.check_circle_rounded
              : Icons.cancel_rounded,
          size: 19,
          color: tone,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          available ? '$score' : '— VERİ BEKLENİYOR',
          style: TextStyle(color: tone, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _WhyCard extends StatelessWidget {
  final StockAnalysis stock;
  final String decisionText;

  const _WhyCard({required this.stock, required this.decisionText});

  @override
  Widget build(BuildContext context) {
    final reasons = <String>[
      if (stock.institutionalScore >= 55)
        'Kurumsal para akışı karar yönünü destekliyor.',
      if (stock.smartMoneyScore >= 55)
        'Smart Money göstergesi pozitif bölgede.',
      if (stock.technicalScore >= 55) 'Teknik yapı ve trend skoru olumlu.',
      if (stock.momentumScore >= 55)
        'Momentum, hareketin devam ihtimalini güçlendiriyor.',
      if (stock.newsScore >= 55) 'Haber etkisi negatif baskı oluşturmuyor.',
      if (stock.riskScore > 55)
        'Risk skoru yüksek olduğu için pozisyon büyüklüğü sınırlı tutulmalı.',
    ];

    if (reasons.isEmpty) {
      reasons.add('Sinyaller karışık; net bir yön için yeni veri bekleniyor.');
    }

    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(
            icon: Icons.help_outline_rounded,
            title: 'AI Neden Böyle Dedi?',
            subtitle: 'Nihai kararın sade ve açıklanabilir gerekçeleri.',
          ),
          const SizedBox(height: 14),
          Text(
            '${stock.symbol} için $decisionText kararının ana nedenleri:',
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (final reason in reasons) ...[
            _Bullet(text: reason, icon: Icons.check_rounded),
            const SizedBox(height: 9),
          ],
        ],
      ),
    );
  }
}

class _InvalidationCard extends StatelessWidget {
  final StockAnalysis stock;

  const _InvalidationCard({required this.stock});

  @override
  Widget build(BuildContext context) {
    final stopText = stock.stop.toStringAsFixed(2);

    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(
            icon: Icons.warning_amber_rounded,
            title: 'Bu Kararı Ne Bozar?',
            subtitle: 'Kararın geçerliliğini kaybettirebilecek koşullar.',
          ),
          const SizedBox(height: 14),
          _Bullet(
            text: '$stopText ₺ stop seviyesinin altında kalıcılık oluşması.',
            icon: Icons.shield_outlined,
          ),
          const SizedBox(height: 10),
          const _Bullet(
            text: 'Kurumsal alımın güçlü satışa dönmesi.',
            icon: Icons.account_balance_outlined,
          ),
          const SizedBox(height: 10),
          const _Bullet(
            text: 'Hacim desteği olmadan fiyatın yükselmeye çalışması.',
            icon: Icons.bar_chart_rounded,
          ),
          const SizedBox(height: 10),
          const _Bullet(
            text: 'Endeks riskinin belirgin şekilde yükselmesi.',
            icon: Icons.public_rounded,
          ),
          const SizedBox(height: 10),
          const _Bullet(
            text: 'Smart Money skorunun negatif bölgeye geçmesi.',
            icon: Icons.radar_rounded,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Header({
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

class _Bullet extends StatelessWidget {
  final String text;
  final IconData icon;

  const _Bullet({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: BrokerColors.primary.withValues(alpha: 0.09),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 15, color: BrokerColors.primary),
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
