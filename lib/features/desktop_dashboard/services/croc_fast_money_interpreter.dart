enum CrocFastMoneyDecision {
  watch,
  strongWatch,
  waitPullback,
  noConfirmation,
  neutral,
}

class CrocFastMoneyInterpretation {
  final CrocFastMoneyDecision decision;
  final String title;
  final String status;
  final String confidence;
  final String summary;
  final List<String> positives;
  final List<String> warnings;

  const CrocFastMoneyInterpretation({
    required this.decision,
    required this.title,
    required this.status,
    required this.confidence,
    required this.summary,
    required this.positives,
    required this.warnings,
  });
}

/// CROC KARAR DILI V1
///
/// FAST MONEY motorunun urettigi teknik degerleri
/// kullanicinin anlayabilecegi karar diline cevirir.
///
/// ONEMLI:
/// - Money Score hesaplamaz.
/// - Crazy Score hesaplamaz.
/// - Memory Score hesaplamaz.
/// - Mevcut gate/esikleri DEGISTIRMEZ.
/// - Yalnizca mevcut sonuclari yorumlar.
class CrocFastMoneyInterpreter {
  const CrocFastMoneyInterpreter();

  CrocFastMoneyInterpretation interpret({
    required int crazyScore,
    required int moneyScore,
    required int memoryScore,
    required double volumeRatio,
    required double volume15Ratio,
    required double cmf,
    required double price,
    required double vwap,
    required double rsi,
    required double changePercent,
  }) {
    final aboveVwap = vwap > 0 && price >= vwap;

    final positives = <String>[];
    final warnings = <String>[];

    if (moneyScore >= 72) {
      positives.add('Para girisi guclu.');
    } else if (moneyScore >= 58) {
      positives.add('Para hareketi dikkat cekiyor.');
    } else {
      warnings.add('Para gucu henuz yeterince yuksek degil.');
    }

    if (memoryScore >= 80) {
      positives.add('Onceki para hareketi guclu sekilde korunuyor.');
    } else if (memoryScore >= 65) {
      positives.add('Para hafizasi hareketi destekliyor.');
    } else {
      warnings.add('Para hafizasi henuz yeterli teyit vermiyor.');
    }

    if (volumeRatio >= 2.0 && volume15Ratio >= 1.5) {
      positives.add('Hacim hareketi birden fazla zaman diliminde destekliyor.');
    } else if (volumeRatio >= 1.35 || volume15Ratio >= 1.25) {
      positives.add('Hacimde dikkat ceken hareket var.');
    } else {
      warnings.add('Hacim teyidi zayif.');
    }

    if (cmf > 0.20) {
      positives.add('Para akisi belirgin sekilde pozitif.');
    } else if (cmf > 0) {
      positives.add('Para akisi pozitif tarafta.');
    } else {
      warnings.add('Para akisi pozitif teyit vermiyor.');
    }

    if (aboveVwap) {
      positives.add('Fiyat VWAP uzerinde tutunuyor.');
    } else {
      warnings.add('Fiyat VWAP altinda; hareket henuz fiyatla teyitli degil.');
    }

    if (rsi >= 82) {
      warnings.add('Fiyat cok gerilmis; kovalamak riskli.');
    } else if (rsi >= 72) {
      warnings.add('Fiyat kisa vadede gerilmis.');
    }

    if (changePercent >= 9.5) {
      warnings.add(
        'Gunluk hareket tavana cok yakin; yeni giris icin risk artmis.',
      );
    }

    final strongStructure =
        crazyScore >= 68 &&
        moneyScore >= 58 &&
        (volumeRatio >= 1.35 || volume15Ratio >= 1.25);

    final earlyStructure =
        crazyScore >= 60 &&
        moneyScore >= 72 &&
        memoryScore >= 65 &&
        volumeRatio >= 2.0 &&
        volume15Ratio >= 1.5 &&
        cmf > 0 &&
        aboveVwap &&
        rsi < 82 &&
        changePercent < 9.5;

    final stretched = rsi >= 72 || changePercent >= 9.5;

    if ((strongStructure || earlyStructure) && aboveVwap && stretched) {
      return CrocFastMoneyInterpretation(
        decision: CrocFastMoneyDecision.waitPullback,
        title: 'GUCLU PARA HAREKETI',
        status: 'GERI CEKILMEYI BEKLE',
        confidence: moneyScore >= 72 && memoryScore >= 80 ? 'YUKSEK' : 'ORTA',
        summary:
            'Hareket guclu gorunuyor fakat fiyat kisa vadede gerilmis. CROC su an kovalamak yerine geri cekilmeyi izliyor.',
        positives: positives,
        warnings: warnings,
      );
    }

    if (earlyStructure) {
      return CrocFastMoneyInterpretation(
        decision: CrocFastMoneyDecision.strongWatch,
        title: 'ERKEN GUCLU PARA HAREKETI',
        status: 'YAKINDAN IZLE',
        confidence: 'YUKSEK',
        summary:
            'Para, hacim, hafiza ve fiyat ayni yonde teyit veriyor. Hareket yakindan izlenmeye deger.',
        positives: positives,
        warnings: warnings,
      );
    }

    if (strongStructure && aboveVwap) {
      return CrocFastMoneyInterpretation(
        decision: CrocFastMoneyDecision.strongWatch,
        title: 'GUCLU PARA HAREKETI',
        status: 'YAKINDAN IZLE',
        confidence: memoryScore >= 65 ? 'YUKSEK' : 'ORTA',
        summary: 'Para ve hacim hareketi fiyat tarafindan da teyit ediliyor.',
        positives: positives,
        warnings: warnings,
      );
    }

    if ((moneyScore >= 55 || volumeRatio >= 1.50 || volume15Ratio >= 1.35) &&
        !aboveVwap) {
      return CrocFastMoneyInterpretation(
        decision: CrocFastMoneyDecision.noConfirmation,
        title: 'HAREKET VAR',
        status: 'FIYAT TEYIDI BEKLE',
        confidence: 'ORTA',
        summary:
            'Para veya hacimde dikkat ceken hareket var ancak fiyat VWAP altinda. CROC teyit bekliyor.',
        positives: positives,
        warnings: warnings,
      );
    }

    if (moneyScore >= 55 || volumeRatio >= 1.50 || volume15Ratio >= 1.35) {
      return CrocFastMoneyInterpretation(
        decision: CrocFastMoneyDecision.watch,
        title: 'DIKKAT CEKEN HAREKET',
        status: 'IZLE',
        confidence: 'ORTA',
        summary:
            'Hissede dikkat ceken para veya hacim hareketi var fakat guclu karar icin ek teyit gerekiyor.',
        positives: positives,
        warnings: warnings,
      );
    }

    return CrocFastMoneyInterpretation(
      decision: CrocFastMoneyDecision.neutral,
      title: 'NORMAL',
      status: 'BEKLE',
      confidence: 'DUSUK',
      summary:
          'CROC su anda belirgin bir para hareketi veya yeterli teyit gormuyor.',
      positives: positives,
      warnings: warnings,
    );
  }
}
