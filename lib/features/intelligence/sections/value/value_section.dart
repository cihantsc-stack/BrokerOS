import 'package:flutter/material.dart';

import '../../../../core/models/stock_analysis.dart';
import '../../../../shared/design/broker_colors.dart';
import '../../../../shared/widgets/broker_card.dart';

class ValueSection extends StatelessWidget {
  final StockAnalysis stock;

  const ValueSection({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final lastPrice = stock.lastPrice ?? 0;

    final valueScore = _calculatePreliminaryValueScore(stock);
    final estimatedFairValue = _calculateEstimatedFairValue(
      lastPrice: lastPrice,
      valueScore: valueScore,
    );

    final marginPercent = lastPrice <= 0
        ? 0.0
        : ((estimatedFairValue - lastPrice) / lastPrice) * 100;

    final valuationStatus = _valuationStatus(marginPercent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BrokerCard(
          glow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.diamond_outlined,
                title: 'Değer Yatırımı Analizi',
                subtitle:
                    'Şirket kalitesi ile fiyatın uzun vadeli değer dengesi.',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _ScoreCircle(score: valueScore),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Değer Puanı',
                          style: TextStyle(
                            color: BrokerColors.textSoft,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$valueScore / 100',
                          style: const TextStyle(
                            color: BrokerColors.primary,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _scoreComment(valueScore),
                          style: const TextStyle(
                            color: BrokerColors.textMain,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        BrokerCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.price_check_rounded,
                title: 'Fiyat ve Gerçek Değer',
                subtitle: 'Güncel fiyatın tahmini gerçek değere göre konumu.',
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _ValueMetric(
                      title: 'Güncel Fiyat',
                      value: lastPrice > 0
                          ? '${lastPrice.toStringAsFixed(2)} ₺'
                          : '--',
                      color: BrokerColors.textMain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ValueMetric(
                      title: 'Tahmini Değer',
                      value: estimatedFairValue > 0
                          ? '${estimatedFairValue.toStringAsFixed(2)} ₺'
                          : '--',
                      color: BrokerColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ValueMetric(
                      title: 'Güvenlik Marjı',
                      value: '${marginPercent.toStringAsFixed(1)}%',
                      color: _marginColor(marginPercent),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ValueMetric(
                      title: 'Değerleme',
                      value: valuationStatus,
                      color: _marginColor(marginPercent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        BrokerCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Şirket Kalitesi',
                subtitle:
                    'Uzun vadeli yatırımcı açısından temel kontrol alanları.',
              ),
              const SizedBox(height: 18),
              _QualityRow(title: 'Kârlılık Kalitesi', score: stock.riskScore),
              _QualityRow(
                title: 'Kurumsal Güven',
                score: stock.institutionalScore,
              ),
              _QualityRow(title: 'Piyasa Algısı', score: stock.newsScore),
              _QualityRow(title: 'İş Modeli Dayanıklılığı', score: valueScore),
            ],
          ),
        ),
        const SizedBox(height: 14),
        BrokerCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.psychology_alt_rounded,
                title: 'CROC AI Değer Yorumu',
                subtitle: 'Uzun vadeli yatırımcı bakışıyla sade değerlendirme.',
              ),
              const SizedBox(height: 16),
              Text(
                _buildAiComment(
                  symbol: stock.symbol,
                  valueScore: valueScore,
                  marginPercent: marginPercent,
                ),
                style: const TextStyle(
                  color: BrokerColors.textMain,
                  fontSize: 14,
                  height: 1.55,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BrokerColors.orange.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: BrokerColors.orange.withValues(alpha: 0.18),
                  ),
                ),
                child: const Text(
                  'Bu bölüm şu anda ön değerleme modeliyle çalışır. '
                  'Bilanço, nakit akışı, borçluluk, ROE ve ROIC verileri '
                  'bağlandığında gerçek Değer Zekâsı Motoru kullanılacaktır.',
                  style: TextStyle(
                    color: BrokerColors.textSoft,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static int _calculatePreliminaryValueScore(StockAnalysis stock) {
    final rawScore =
        (stock.riskScore + stock.institutionalScore + stock.newsScore) / 3;
    return rawScore.round().clamp(0, 100);
  }

  static double _calculateEstimatedFairValue({
    required double lastPrice,
    required int valueScore,
  }) {
    if (lastPrice <= 0) return 0;
    final adjustment = (valueScore - 70) / 200;
    return lastPrice * (1 + adjustment);
  }

  static String _valuationStatus(double marginPercent) {
    if (marginPercent >= 15) return 'İskontolu';
    if (marginPercent <= -15) return 'Pahalı';
    return 'Makul Değer';
  }

  static Color _marginColor(double marginPercent) {
    if (marginPercent >= 15) return BrokerColors.green;
    if (marginPercent <= -15) return BrokerColors.red;
    return BrokerColors.orange;
  }

  static String _scoreComment(int score) {
    if (score >= 85) return 'Uzun vadeli kalite görünümü güçlü.';
    if (score >= 70) {
      return 'Şirket kalitesi olumlu ancak fiyat dikkatle izlenmeli.';
    }
    if (score >= 55) {
      return 'Temel görünüm dengeli fakat güçlü güvenlik marjı yok.';
    }
    return 'Uzun vadeli yatırım açısından ek inceleme gerekiyor.';
  }

  static String _buildAiComment({
    required String symbol,
    required int valueScore,
    required double marginPercent,
  }) {
    if (valueScore >= 85 && marginPercent >= 10) {
      return '$symbol uzun vadeli şirket kalitesi ve fiyat/değer dengesi '
          'açısından olumlu bölgede bulunuyor. Güvenlik marjı korunursa '
          'kademeli değerlendirme yapılabilir.';
    }
    if (valueScore >= 70 && marginPercent > -10) {
      return '$symbol şirket kalitesi açısından olumlu görünse de güncel '
          'fiyat tahmini gerçek değere yakın. Yeni alım için daha iyi fiyat '
          'veya finansal sonuç teyidi beklemek daha dengeli olabilir.';
    }
    return '$symbol için fiyat ve uzun vadeli değer dengesi yeterince güçlü '
        'değil. Teknik yükseliş tek başına yatırım gerekçesi kabul edilmemeli; '
        'bilanço ve nakit üretimi ayrıca incelenmelidir.';
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
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: BrokerColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: BrokerColors.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Icon(icon, color: BrokerColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: BrokerColors.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: BrokerColors.textSoft,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreCircle extends StatelessWidget {
  final int score;
  const _ScoreCircle({required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
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
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueMetric extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _ValueMetric({
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
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _QualityRow extends StatelessWidget {
  final String title;
  final int score;

  const _QualityRow({required this.title, required this.score});

  @override
  Widget build(BuildContext context) {
    final normalizedScore = score.clamp(0, 100);
    final color = normalizedScore >= 80
        ? BrokerColors.green
        : normalizedScore >= 60
        ? BrokerColors.orange
        : BrokerColors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: BrokerColors.textMain,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$normalizedScore',
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: normalizedScore / 100,
              minHeight: 8,
              backgroundColor: BrokerColors.borderSoft,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
