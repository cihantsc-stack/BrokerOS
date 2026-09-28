/// Institutional evidence is never inferred from anonymous price/volume bars.
/// A verified participant feed is required for participant-level claims.
enum CrocInstitutionalEvidence {
  unavailable,
  technicalProxy,
  verifiedParticipantFlow,
}

class CrocInstitutionalStrength {
  final CrocInstitutionalEvidence evidence;
  final String label;
  final String explanation;
  final double? verifiedNetLots;

  const CrocInstitutionalStrength({
    required this.evidence,
    required this.label,
    required this.explanation,
    this.verifiedNetLots,
  });
}

/// Provider metadata supplied by a trusted adapter, never from a price feed.
class CrocInstitutionalSource {
  final String provider;
  final DateTime observedAt;
  final bool authenticated;

  const CrocInstitutionalSource({
    required this.provider,
    required this.observedAt,
    required this.authenticated,
  });
}

/// Per-participant totals from an authorized, externally verified source.
/// Aggregating these rows does not imply that every broker trade belongs
/// to a single institutional investor.
class CrocParticipantFlow {
  final String participant;
  final double buyLots;
  final double sellLots;

  const CrocParticipantFlow({
    required this.participant,
    required this.buyLots,
    required this.sellLots,
  });

  double get netLots => buyLots - sellLots;
}

class CrocParticipantFlowReport {
  final CrocInstitutionalSource source;
  final List<CrocParticipantFlow> participants;
  final double totalBuyLots;
  final double totalSellLots;

  const CrocParticipantFlowReport({
    required this.source,
    required this.participants,
    required this.totalBuyLots,
    required this.totalSellLots,
  });

  double get netLots => totalBuyLots - totalSellLots;
}

class CrocParticipantFlowAggregator {
  const CrocParticipantFlowAggregator();

  /// Returns null when data provenance, age, or row integrity is insufficient.
  CrocParticipantFlowReport? aggregate({
    required CrocInstitutionalSource source,
    required List<CrocParticipantFlow> rows,
    required DateTime asOf,
  }) {
    if (!source.authenticated ||
        source.provider.trim().isEmpty ||
        source.observedAt.isAfter(asOf) ||
        asOf.difference(source.observedAt) > const Duration(days: 1) ||
        rows.isEmpty) {
      return null;
    }

    final names = <String>{};
    var buys = 0.0;
    var sells = 0.0;
    for (final row in rows) {
      final name = row.participant.trim().toUpperCase();
      if (name.isEmpty ||
          !names.add(name) ||
          !row.buyLots.isFinite ||
          !row.sellLots.isFinite ||
          row.buyLots < 0 ||
          row.sellLots < 0) {
        return null;
      }
      buys += row.buyLots;
      sells += row.sellLots;
    }
    if (!buys.isFinite || !sells.isFinite) return null;
    final ordered = List<CrocParticipantFlow>.of(rows)
      ..sort((a, b) => b.netLots.compareTo(a.netLots));
    return CrocParticipantFlowReport(
      source: source,
      participants: List<CrocParticipantFlow>.unmodifiable(ordered),
      totalBuyLots: buys,
      totalSellLots: sells,
    );
  }
}

class CrocInstitutionalStrengthEngine {
  const CrocInstitutionalStrengthEngine();

  CrocInstitutionalStrength evaluate({
    required double? cmf,
    required double? vwap,
    required double? price,
    required double? volumeRatio,
    double? verifiedBuyLots,
    double? verifiedSellLots,
    CrocInstitutionalSource? participantSource,
    DateTime? asOf,
  }) {
    final evaluationTime = asOf ?? DateTime.now();
    final sourceIsValid = participantSource != null &&
        participantSource.authenticated &&
        participantSource.provider.trim().isNotEmpty &&
        !participantSource.observedAt.isAfter(evaluationTime) &&
        evaluationTime.difference(participantSource.observedAt) <=
            const Duration(days: 1);

    if (sourceIsValid &&
        verifiedBuyLots != null &&
        verifiedSellLots != null &&
        verifiedBuyLots.isFinite &&
        verifiedSellLots.isFinite &&
        verifiedBuyLots >= 0 &&
        verifiedSellLots >= 0) {
      final net = verifiedBuyLots - verifiedSellLots;
      return CrocInstitutionalStrength(
        evidence: CrocInstitutionalEvidence.verifiedParticipantFlow,
        label: net > 0
            ? 'DOĞRULANMIŞ NET ALIM'
            : net < 0
                ? 'DOĞRULANMIŞ NET SATIM'
                : 'DOĞRULANMIŞ DENGE',
        explanation: 'Doğrulanmış kaynak: ${participantSource!.provider}. '
            'Güncel katılımcı işlem verisi; tek başına yatırım kararı değildir.',
        verifiedNetLots: net,
      );
    }

    if (cmf == null ||
        vwap == null ||
        price == null ||
        volumeRatio == null ||
        !cmf.isFinite ||
        !vwap.isFinite ||
        !price.isFinite ||
        !volumeRatio.isFinite ||
        vwap <= 0 ||
        price <= 0 ||
        volumeRatio <= 0) {
      return const CrocInstitutionalStrength(
        evidence: CrocInstitutionalEvidence.unavailable,
        label: 'KURUM VERİSİ YOK',
        explanation: 'Kurumsal işlem veya yeterli teknik veri bulunmuyor.',
      );
    }

    final positive = cmf > 0.05 && price > vwap && volumeRatio >= 1.5;
    final negative = cmf < -0.05 && price < vwap && volumeRatio >= 1.5;

    return CrocInstitutionalStrength(
      evidence: CrocInstitutionalEvidence.technicalProxy,
      label: positive
          ? 'TEKNİK PARA AKIŞI +'
          : negative
              ? 'TEKNİK PARA AKIŞI -'
              : 'TEKNİK AKIŞ KARARSIZ',
      explanation: 'CMF, VWAP ve hacimden türetilmiş teknik gösterge. '
          'Aracı kurum veya fon alım-satımını doğrulamaz.',
    );
  }
}
