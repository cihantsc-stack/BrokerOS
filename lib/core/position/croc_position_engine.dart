class CrocPositionResult {
  const CrocPositionResult({
    required this.decision,
    required this.pnlPercent,
    required this.reason,
    required this.actionLine,
  });

  final String decision;
  final double pnlPercent;
  final String reason;
  final String actionLine;
}

class CrocPositionEngine {
  const CrocPositionEngine();

  CrocPositionResult evaluate({
    required double currentPrice,
    required double averageCost,
    required int masterScore,
    required String riskLabel,
    required double stop,
    required double target,
  }) {
    if (currentPrice <= 0 || averageCost <= 0) {
      return const CrocPositionResult(
        decision: 'VER\u0130 BEKLEN\u0130YOR',
        pnlPercent: 0,
        reason: 'Maliyet ve g\u00fcncel fiyat gerekli.',
        actionLine: 'Maliyet bilgisini kontrol et.',
      );
    }

    final pnl = ((currentPrice - averageCost) / averageCost) * 100;
    final risk = riskLabel.toUpperCase();
    final highRisk =
        risk.contains('Y\u00dcKSEK') ||
        risk.contains('HIGH') ||
        risk.contains('KR\u0130T\u0130K');
    final stopBroken = stop > 0 && currentPrice <= stop;
    final targetReached = target > 0 && currentPrice >= target;

    if (stopBroken) {
      return CrocPositionResult(
        decision: '\u00c7IKI\u015eI DE\u011eERLEND\u0130R',
        pnlPercent: pnl,
        reason: 'Fiyat CROC stop seviyesine indi veya alt\u0131na ge\u00e7ti.',
        actionLine: 'Pozisyon riskini yeniden de\u011ferlendir.',
      );
    }

    if (masterScore < 35) {
      return CrocPositionResult(
        decision: pnl > 0
            ? 'R\u0130SK AZALT'
            : '\u00c7IKI\u015eI DE\u011eERLEND\u0130R',
        pnlPercent: pnl,
        reason:
            'CROC ana skoru zay\u0131f; teknik yap\u0131 yeni risk ta\u015f\u0131mak i\u00e7in uygun de\u011fil.',
        actionLine: stop > 0
            ? 'Stop ${stop.toStringAsFixed(2)} alt\u0131nda pozisyon ta\u015f\u0131ma.'
            : 'Pozisyon b\u00fcy\u00fckl\u00fc\u011f\u00fcn\u00fc azaltmay\u0131 de\u011ferlendir.',
      );
    }

    if (masterScore >= 70 && highRisk) {
      if (pnl >= 7 || targetReached) {
        return CrocPositionResult(
          decision: 'K\u00c2RI KORU',
          pnlPercent: pnl,
          reason:
              'Ana trend g\u00fc\u00e7l\u00fc ancak risk y\u00fcksek; mevcut k\u00e2r\u0131n korunmas\u0131 \u00f6ncelikli.',
          actionLine: stop > 0
              ? 'Takip seviyesi: ${stop.toStringAsFixed(2)}'
              : 'K\u00e2r\u0131 koruyan disiplinli stop kullan.',
        );
      }
      if (pnl >= 0) {
        return CrocPositionResult(
          decision: 'TUT',
          pnlPercent: pnl,
          reason:
              'CROC skoru g\u00fc\u00e7l\u00fc; risk y\u00fcksek olsa da stop bozulmad\u0131.',
          actionLine: stop > 0
              ? '${stop.toStringAsFixed(2)} alt\u0131nda yeniden de\u011ferlendir.'
              : 'Riski yak\u0131ndan takip et.',
        );
      }
      return CrocPositionResult(
        decision: 'R\u0130SK AZALT',
        pnlPercent: pnl,
        reason:
            'CROC skoru g\u00fc\u00e7l\u00fc fakat y\u00fcksek risk ve maliyet alt\u0131 fiyat birlikte bask\u0131 yarat\u0131yor.',
        actionLine: stop > 0
            ? 'Stop ${stop.toStringAsFixed(2)} kritik.'
            : 'Pozisyon b\u00fcy\u00fckl\u00fc\u011f\u00fcn\u00fc azaltmay\u0131 de\u011ferlendir.',
      );
    }

    if (highRisk) {
      return CrocPositionResult(
        decision: pnl >= 5 ? 'K\u00c2RI KORU' : 'R\u0130SK AZALT',
        pnlPercent: pnl,
        reason:
            'Risk seviyesi y\u00fcksek; pozisyon y\u00f6netimi yeni al\u0131m karar\u0131ndan daha temkinli olmal\u0131.',
        actionLine: stop > 0
            ? 'Stop ${stop.toStringAsFixed(2)} seviyesini izle.'
            : 'Pozisyon riskini azalt.',
      );
    }

    if (masterScore >= 50) {
      return CrocPositionResult(
        decision: pnl >= 10 || targetReached ? 'K\u00c2RI KORU' : 'TUT',
        pnlPercent: pnl,
        reason: masterScore >= 70
            ? 'CROC ana skoru g\u00fc\u00e7l\u00fc ve stop seviyesi korunuyor.'
            : 'G\u00f6r\u00fcn\u00fcm pozisyonu korumaya uygun, ancak yeni risk eklemek i\u00e7in ana karar ayr\u0131 de\u011ferlendirilir.',
        actionLine: stop > 0
            ? '${stop.toStringAsFixed(2)} alt\u0131nda yeniden de\u011ferlendir.'
            : 'Stop disiplinini koru.',
      );
    }

    return CrocPositionResult(
      decision: pnl < -5 ? 'R\u0130SK AZALT' : 'TUT',
      pnlPercent: pnl,
      reason:
          'Ana skor orta-zay\u0131f b\u00f6lgede; stop bozulmad\u0131\u011f\u0131 s\u00fcrece pozisyon ile yeni al\u0131m karar\u0131 ayr\u0131 tutuluyor.',
      actionLine: stop > 0
          ? 'Stop ${stop.toStringAsFixed(2)} kritik takip seviyesi.'
          : 'Pozisyonu yak\u0131ndan izle.',
    );
  }
}
