import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class NextStepCard extends StatelessWidget {
  final StockAnalysis stock;

  const NextStepCard({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final double currentPrice = stock.lastPrice ?? stock.entry;
    final _PriceState state = _stateFor(currentPrice);

    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ŞİMDİ NEYİ BEKLEMELİYİM?',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Fiyat değiştikçe ne yapacağını önceden bil.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.35),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: state.tone.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: state.tone.withValues(alpha: 0.22)),
            ),
            child: Row(
              children: [
                Icon(state.icon, color: state.tone, size: 29),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.title,
                        style: TextStyle(
                          color: state.tone,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.explanation,
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
          _ActionLine(
            icon: Icons.login_rounded,
            tone: BrokerColors.primary,
            title: 'Fiyat giriş bölgesine gelirse',
            text:
                '${stock.entry.toStringAsFixed(2)} ₺ civarında küçük veya kademeli işlem düşünülebilir.',
          ),
          _ActionLine(
            icon: Icons.trending_up_rounded,
            tone: BrokerColors.green,
            title: 'Fiyat hedefe ulaşırsa',
            text:
                '${stock.target1.toStringAsFixed(2)} ₺ civarında kârın bir kısmını almak düşünülebilir.',
          ),
          _ActionLine(
            icon: Icons.health_and_safety_rounded,
            tone: BrokerColors.red,
            title: 'Fiyat zarar sınırına inerse',
            text:
                '${stock.stop.toStringAsFixed(2)} ₺ altında planı yeniden değerlendir; zararı büyütme.',
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BrokerColors.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: BrokerColors.primary,
                  size: 19,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'En önemli kural: İşleme girmeden önce çıkış planını belirle.',
                    style: TextStyle(
                      color: BrokerColors.textMain,
                      height: 1.35,
                      fontWeight: FontWeight.w800,
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

  _PriceState _stateFor(double currentPrice) {
    if (currentPrice <= stock.stop) {
      return const _PriceState(
        title: 'PLAN BOZULDU',
        explanation:
            'Fiyat zarar sınırına geldi veya altına indi. Yeni işlem açmak yerine riski azalt.',
        tone: BrokerColors.red,
        icon: Icons.dangerous_rounded,
      );
    }

    if (currentPrice >= stock.target1) {
      return const _PriceState(
        title: 'HEDEFE ULAŞTI',
        explanation:
            'İlk hedef görüldü. Kârın bir kısmını korumak düşünülebilir.',
        tone: BrokerColors.green,
        icon: Icons.flag_rounded,
      );
    }

    final double distanceToEntry =
        ((currentPrice - stock.entry).abs() / stock.entry) * 100;

    if (distanceToEntry <= 1.5) {
      return const _PriceState(
        title: 'GİRİŞ BÖLGESİNDE',
        explanation:
            'Fiyat planlanan giriş seviyesine yakın. Kademeli hareket etmek daha güvenli.',
        tone: BrokerColors.primary,
        icon: Icons.near_me_rounded,
      );
    }

    if (currentPrice > stock.entry) {
      return const _PriceState(
        title: 'PLAN DEVAM EDİYOR',
        explanation:
            'Fiyat giriş seviyesinin üzerinde ve ilk hedefin altında. Stop seviyesini takip et.',
        tone: BrokerColors.green,
        icon: Icons.route_rounded,
      );
    }

    return const _PriceState(
      title: 'GİRİŞİ BEKLE',
      explanation:
          'Fiyat henüz planlanan giriş seviyesinde değil. Acele etmek yerine uygun bölgeyi bekle.',
      tone: BrokerColors.primary,
      icon: Icons.hourglass_top_rounded,
    );
  }
}

class _ActionLine extends StatelessWidget {
  final IconData icon;
  final Color tone;
  final String title;
  final String text;

  const _ActionLine({
    required this.icon,
    required this.tone,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: tone, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: BrokerColors.textMain,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    height: 1.35,
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

class _PriceState {
  final String title;
  final String explanation;
  final Color tone;
  final IconData icon;

  const _PriceState({
    required this.title,
    required this.explanation,
    required this.tone,
    required this.icon,
  });
}
