import 'package:flutter/material.dart';

import '../../core/engine/broker_engine.dart';
import '../../features/intelligence/broker_intelligence_screen.dart';
import '../../shared/design/broker_colors.dart';
import '../../shared/glossary/interactive_glossary_text.dart';
import '../../shared/widgets/broker_card.dart';
import '../../shared/widgets/broker_page.dart';

class RadarScreen extends StatelessWidget {
  const RadarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stocks = BrokerEngine.run();

    return BrokerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _RadarHeader(),
          const SizedBox(height: 20),
          ...stocks.map(
            (stock) => Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: BrokerCard(
                glow: stock.aiScore >= 90,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BrokerIntelligenceScreen(symbol: stock.symbol)),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stock.symbol,
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: BrokerColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(stock.company, style: const TextStyle(color: BrokerColors.textSoft, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        _ScoreCircle(score: stock.aiScore),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _Mini(title: 'Karar', value: stock.decision, color: stock.decision.contains('AL') ? BrokerColors.green : BrokerColors.orange)),
                        const SizedBox(width: 10),
                        Expanded(child: _Mini(title: 'Risk', value: stock.risk, color: stock.risk == 'Orta' ? BrokerColors.orange : BrokerColors.green)),
                        const SizedBox(width: 10),
                        Expanded(child: _Mini(title: 'Güven', value: '%${stock.confidence}', color: BrokerColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    InteractiveGlossaryText('Neden: ${stock.reasons.join(", ")}. Smart Money ve Momentum birlikte okunur.'),
                    const SizedBox(height: 14),
                    const Row(
                      children: [
                        Text('CROC AI raporunu aç', style: TextStyle(color: BrokerColors.primary, fontWeight: FontWeight.w900)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, color: BrokerColors.primary, size: 18),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarHeader extends StatelessWidget {
  const _RadarHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Radar', style: TextStyle(color: BrokerColors.textMain, fontSize: 36, fontWeight: FontWeight.w900)),
        SizedBox(height: 8),
        Text('CROC AI bugün filtreyi geçen en güçlü fırsatları taradı.', style: TextStyle(color: BrokerColors.textSoft, fontSize: 15)),
      ],
    );
  }
}

class _ScoreCircle extends StatelessWidget {
  final int score;
  const _ScoreCircle({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: BrokerColors.primary.withOpacity(.10),
        border: Border.all(color: BrokerColors.primary.withOpacity(.35)),
      ),
      child: Center(
        child: Text('$score', style: const TextStyle(color: BrokerColors.primary, fontSize: 20, fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _Mini({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: BrokerColors.textSoft, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text(value, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
