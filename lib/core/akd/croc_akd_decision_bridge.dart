import 'croc_akd_models.dart';

/// Safe boundary between raw AKD concentration analysis and downstream
/// decision/scoring code. It does not add points by itself.
enum CrocAkdDecisionBias {
  unavailable,
  buyer,
  seller,
  neutral,
}

class CrocAkdDecisionEvidence {
  const CrocAkdDecisionEvidence({
    required this.bias,
    required this.isEligible,
    required this.reason,
  });

  final CrocAkdDecisionBias bias;
  final bool isEligible;
  final String reason;
}

class CrocAkdDecisionBridge {
  const CrocAkdDecisionBridge();

  CrocAkdDecisionEvidence inspect(CrocAkdResult result) {
    if (result.rows.isEmpty) {
      return const CrocAkdDecisionEvidence(
        bias: CrocAkdDecisionBias.unavailable,
        isEligible: false,
        reason: 'AKD verisi yok.',
      );
    }

    if (!result.isBalancedNetBook ||
        result.signal == CrocAkdConcentrationSignal.insufficientData) {
      return const CrocAkdDecisionEvidence(
        bias: CrocAkdDecisionBias.unavailable,
        isEligible: false,
        reason: 'AKD defteri eksik veya net lot dengesi doğrulanamadı.',
      );
    }

    if (result.isFlowDistorted ||
        result.signal == CrocAkdConcentrationSignal.distorted) {
      return const CrocAkdDecisionEvidence(
        bias: CrocAkdDecisionBias.unavailable,
        isEligible: false,
        reason: 'AKD akışı tek taraflı/bozulmuş; yön teyidi olarak kullanılamaz.',
      );
    }

    return switch (result.signal) {
      CrocAkdConcentrationSignal.buyerConcentrated =>
        const CrocAkdDecisionEvidence(
          bias: CrocAkdDecisionBias.buyer,
          isEligible: true,
          reason: 'Geçerli AKD defterinde alıcı yoğunlaşması var.',
        ),
      CrocAkdConcentrationSignal.sellerConcentrated =>
        const CrocAkdDecisionEvidence(
          bias: CrocAkdDecisionBias.seller,
          isEligible: true,
          reason: 'Geçerli AKD defterinde satıcı yoğunlaşması var.',
        ),
      CrocAkdConcentrationSignal.balanced =>
        const CrocAkdDecisionEvidence(
          bias: CrocAkdDecisionBias.neutral,
          isEligible: true,
          reason: 'Geçerli AKD defteri dengeli.',
        ),
      CrocAkdConcentrationSignal.distorted ||
      CrocAkdConcentrationSignal.insufficientData =>
        const CrocAkdDecisionEvidence(
          bias: CrocAkdDecisionBias.unavailable,
          isEligible: false,
          reason: 'AKD yön teyidi için uygun değil.',
        ),
    };
  }
}
