import 'package:flutter/material.dart';

import '../../../core/bist/data/bist100_demo_data_source.dart';
import '../../../core/bist/services/bist100_intelligence_service.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class Bist100IntelligenceHomeCard extends StatelessWidget {
  const Bist100IntelligenceHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final result = const Bist100IntelligenceService().analyze(
      const Bist100DemoDataSource().load(),
    );
    final breadth = result.breadth;
    final sectors = result.sectors.take(3).toList(growable: false);
    final stocks = result.strongestStocks.take(5).toList(growable: false);

    return BrokerCard(
      glow: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: BrokerColors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: BrokerColors.primary.withValues(alpha: .28),
                  ),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: BrokerColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BIST 100 Intelligence',
                      style: TextStyle(
                        color: BrokerColors.textMain,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '100 hissenin piyasa genişliği ve sektör gücü',
                      style: TextStyle(
                        color: BrokerColors.textSoft,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _ScoreBadge(score: breadth.score),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetricBox(label: 'Taranan', value: '${breadth.total}'),
              _MetricBox(label: 'Yükselen', value: '${breadth.rising}'),
              _MetricBox(label: 'Düşen', value: '${breadth.falling}'),
              _MetricBox(
                label: 'Ortalama',
                value:
                    '${breadth.averageChange >= 0 ? '+' : ''}%${breadth.averageChange.toStringAsFixed(2)}',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _decisionText(breadth.score),
            style: const TextStyle(
              color: BrokerColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${breadth.rising} hisse yükselirken ${breadth.falling} hisse düşüyor. '
            'Piyasa genişliği ${breadth.healthLabel.toLowerCase()} görünümde.',
            style: const TextStyle(
              color: BrokerColors.textSoft,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle(title: 'Güçlü sektörler'),
          const SizedBox(height: 10),
          ...sectors.map(
            (sector) => _SectorRow(
              name: sector.sector,
              change: sector.averageChange,
              score: sector.score,
            ),
          ),
          const SizedBox(height: 18),
          const _SectionTitle(title: 'Öne çıkan 5 hisse'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: stocks
                .map(
                  (tick) => _StockChip(
                    code: tick.stock.code,
                    change: tick.changePercent,
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 15,
                color: BrokerColors.textMuted,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Şimdilik yerel demo verisi kullanılıyor. Canlı veri geçidi sonraki sprintte bağlanacak.',
                  style: TextStyle(
                    color: BrokerColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _decisionText(int score) {
    if (score >= 75) return 'GÜÇLÜ POZİTİF';
    if (score >= 60) return 'SEÇİCİ ALIM';
    if (score >= 42) return 'TEMKİNLİ BEKLE';
    if (score >= 25) return 'RİSK AZALT';
    return 'SAVUNMA MODU';
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: BrokerColors.cardDeep,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BrokerColors.border),
      ),
      child: Column(
        children: [
          Text(
            '$score',
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            'SKOR',
            style: TextStyle(
              color: BrokerColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;

  const _MetricBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: BrokerColors.cardDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: BrokerColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: BrokerColors.textSoft,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: .7,
      ),
    );
  }
}

class _SectorRow extends StatelessWidget {
  final String name;
  final double change;
  final int score;

  const _SectorRow({
    required this.name,
    required this.change,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: BrokerColors.textMain,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${change >= 0 ? '+' : ''}%${change.toStringAsFixed(2)}',
            style: TextStyle(
              color: change >= 0 ? BrokerColors.green : BrokerColors.red,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 28,
            child: Text(
              '$score',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: BrokerColors.textSoft,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StockChip extends StatelessWidget {
  final String code;
  final double change;

  const _StockChip({required this.code, required this.change});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: BrokerColors.cardDeep,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            code,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            '${change >= 0 ? '+' : ''}%${change.toStringAsFixed(2)}',
            style: TextStyle(
              color: change >= 0 ? BrokerColors.green : BrokerColors.red,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
