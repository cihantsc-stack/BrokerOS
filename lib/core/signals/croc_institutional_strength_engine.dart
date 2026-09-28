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

class CrocInstitutionalStrengthEngine {
  const CrocInstitutionalStrengthEngine();

  CrocInstitutionalStrength evaluate({
    required double? cmf,
    required double? vwap,
    required double? price,
    required double? volumeRatio,
    double? verifiedBuyLots,
    double? verifiedSellLots,
    bool participantDataVerified = false,
  }) {
    if (participantDataVerified &&
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
        explanation: 'Kaynağı doğrulanmış katılımcı işlem verisi. '
            'Tek başına yatırım kararı değildir.',
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
