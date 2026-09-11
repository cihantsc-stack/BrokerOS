import '../ai/council/council_result.dart';
import '../models/stock_analysis.dart';
import 'decision_dna.dart';
import 'dna_factor.dart';

class BrokerDnaEngine {
  const BrokerDnaEngine._();

  static DecisionDna analyze({
    required StockAnalysis stock,
    required CouncilResult council,
  }) {
    final base = <_RawFactor>[
      _RawFactor(
        name: 'Smart Money',
        score: stock.smartMoneyScore,
        weight: 0.24,
        interpretation: 'Kurumsal para kararın ana genini oluşturuyor.',
      ),
      _RawFactor(
        name: 'Teknik',
        score: stock.technicalScore,
        weight: 0.20,
        interpretation: 'Trend ve teknik yapı karar yönünü destekliyor.',
      ),
      _RawFactor(
        name: 'Momentum',
        score: stock.momentumScore,
        weight: 0.16,
        interpretation: 'Fiyat hareketinin gücü kararın hızını belirliyor.',
      ),
      _RawFactor(
        name: 'Risk',
        score: stock.riskScore,
        weight: 0.16,
        interpretation: 'Risk kalitesi kararın uygulanabilirliğini belirliyor.',
      ),
      _RawFactor(
        name: 'Game Theory',
        score:
            ((stock.smartMoneyScore * 0.40) +
                    (stock.institutionalScore * 0.35) +
                    (stock.momentumScore * 0.25))
                .round(),
        weight: 0.14,
        interpretation:
            'Büyük oyuncu davranışı olası senaryoyu şekillendiriyor.',
      ),
      _RawFactor(
        name: 'Haber',
        score: stock.newsScore,
        weight: 0.10,
        interpretation: 'Haber akışı kararın dışsal etkisini oluşturuyor.',
      ),
    ];

    final contributions = base
        .map((factor) => (factor.score.clamp(0, 100) * factor.weight).round())
        .toList();

    final totalContribution = contributions.fold<int>(
      0,
      (sum, value) => sum + value,
    );

    final factors = <DnaFactor>[];
    for (int index = 0; index < base.length; index++) {
      final raw = base[index];
      final contribution = contributions[index];
      final share = totalContribution == 0
          ? 0
          : ((contribution / totalContribution) * 100).round();

      factors.add(
        DnaFactor(
          name: raw.name,
          rawScore: raw.score.clamp(0, 100),
          weight: raw.weight,
          contribution: contribution,
          share: share,
          interpretation: raw.interpretation,
        ),
      );
    }

    factors.sort((a, b) => b.share.compareTo(a.share));

    return DecisionDna(
      decision: council.finalDecision,
      totalPower: council.confidence,
      dominantGene: factors.first.name,
      profile: _profile(factors),
      factors: List<DnaFactor>.unmodifiable(factors),
    );
  }

  static String _profile(List<DnaFactor> factors) {
    final dominant = factors.first;

    if (dominant.name == 'Smart Money') {
      return 'Kurumsal Para Odaklı';
    }

    if (dominant.name == 'Teknik') {
      return 'Trend Odaklı';
    }

    if (dominant.name == 'Momentum') {
      return 'Momentum Odaklı';
    }

    if (dominant.name == 'Risk') {
      return 'Risk Kontrollü';
    }

    if (dominant.name == 'Haber') {
      return 'Haber Duyarlı';
    }

    return 'Oyuncu Davranışı Odaklı';
  }
}

class _RawFactor {
  final String name;
  final int score;
  final double weight;
  final String interpretation;

  const _RawFactor({
    required this.name,
    required this.score,
    required this.weight,
    required this.interpretation,
  });
}
