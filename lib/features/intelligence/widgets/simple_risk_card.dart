import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class SimpleRiskCard extends StatelessWidget {
  final StockAnalysis stock;

  const SimpleRiskCard({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final String level = _riskLevel(stock.riskScore);
    final Color tone = _riskTone(stock.riskScore);

    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RİSK DURUMU',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Bu işlemde dikkat edilmesi gereken en önemli nokta.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.35),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tone.withValues(alpha: 0.22)),
            ),
            child: Row(
              children: [
                Icon(_riskIcon(stock.riskScore), color: tone, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level,
                        style: TextStyle(
                          color: tone,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _riskExplanation(stock.riskScore),
                        style: const TextStyle(
                          color: BrokerColors.textMain,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          _WarningLine(
            text:
                '${stock.stop.toStringAsFixed(2)} ₺ altında günlük kapanış olursa işlem planı bozulur.',
          ),
          const _WarningLine(
            text:
                'Fiyat yükselirken işlem hacmi zayıflarsa yükseliş güven kaybedebilir.',
          ),
          const _WarningLine(
            text:
                'Tek seferde yüksek miktarla işlem yapmak yerine kademeli hareket et.',
          ),
          const SizedBox(height: 8),
          Text(
            'Teknik risk puanı: ${stock.riskScore}/100',
            style: const TextStyle(color: BrokerColors.textSoft, fontSize: 10),
          ),
        ],
      ),
    );
  }

  String _riskLevel(int score) {
    if (score >= 75) {
      return 'DÜŞÜK RİSK';
    }
    if (score >= 50) {
      return 'ORTA RİSK';
    }
    return 'YÜKSEK RİSK';
  }

  String _riskExplanation(int score) {
    if (score >= 75) {
      return 'Risk şu an kontrol edilebilir görünüyor. Stop seviyesine yine de uyulmalı.';
    }
    if (score >= 50) {
      return 'İşlem yapılabilir ancak fiyat hareketleri yakından takip edilmeli.';
    }
    return 'Fiyat hareketi sert olabilir. Yeni işlem açarken çok dikkatli olunmalı.';
  }

  Color _riskTone(int score) {
    if (score >= 75) {
      return BrokerColors.green;
    }
    if (score >= 50) {
      return BrokerColors.primary;
    }
    return BrokerColors.red;
  }

  IconData _riskIcon(int score) {
    if (score >= 75) {
      return Icons.shield_rounded;
    }
    if (score >= 50) {
      return Icons.warning_amber_rounded;
    }
    return Icons.dangerous_rounded;
  }
}

class _WarningLine extends StatelessWidget {
  final String text;

  const _WarningLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, color: BrokerColors.textSoft, size: 7),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: BrokerColors.textSoft,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
