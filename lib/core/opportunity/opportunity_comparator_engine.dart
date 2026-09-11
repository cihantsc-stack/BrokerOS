import 'opportunity_candidate.dart';

class OpportunityComparatorEngine {
  OpportunityComparatorEngine._();

  static final OpportunityComparatorEngine instance =
      OpportunityComparatorEngine._();

  Future<List<OpportunityCandidate>> compare(String currentSymbol) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final int seed = currentSymbol.codeUnits.fold<int>(
      0,
      (int total, int value) => total + value,
    );

    final double currentScore = (82.0 + (seed % 10).toDouble()).clamp(
      0.0,
      100.0,
    );

    final List<OpportunityCandidate> pool = <OpportunityCandidate>[
      OpportunityCandidate(
        symbol: currentSymbol,
        score: currentScore,
        reason: 'Mevcut analiz edilen fırsat',
        isCurrent: true,
      ),
      const OpportunityCandidate(
        symbol: 'THYAO',
        score: 94.0,
        reason: 'Kurumsal para ve hacim birlikte güçlü',
        isCurrent: false,
      ),
      const OpportunityCandidate(
        symbol: 'ASELS',
        score: 92.0,
        reason: 'Gizli toplama ve teknik momentum yüksek',
        isCurrent: false,
      ),
      const OpportunityCandidate(
        symbol: 'AKBNK',
        score: 88.0,
        reason: 'Sektör desteği ve yabancı ilgisi olumlu',
        isCurrent: false,
      ),
    ];

    pool.sort(
      (OpportunityCandidate a, OpportunityCandidate b) =>
          b.score.compareTo(a.score),
    );

    return pool;
  }
}
