import '../../../core/bist/models/sector_strength.dart';
import '../models/daily_trade_candidate.dart';

class MarketMasterDecision {
  final int score;
  final int tradeAverage;
  final int sectorScore;
  final int globalScore;
  final String mode;
  final String grade;
  final String aiDecision;
  final String riskLabel;
  final String comment;

  const MarketMasterDecision({
    required this.score,
    required this.tradeAverage,
    required this.sectorScore,
    required this.globalScore,
    required this.mode,
    required this.grade,
    required this.aiDecision,
    required this.riskLabel,
    required this.comment,
  });
}

class MarketMasterDecisionService {
  const MarketMasterDecisionService();

  MarketMasterDecision evaluate({
    required List<DailyTradeCandidate> candidates,
    required List<SectorStrength> sectors,
    required int globalScore,
  }) {
    final topFive = candidates.take(5).toList(growable: false);

    final tradeAverage = topFive.isEmpty
        ? 50
        : (topFive.fold<int>(0, (sum, item) => sum + item.crocScore) /
                  topFive.length)
              .round();

    final sectorScore = sectors.isEmpty
        ? 50
        : (sectors.take(4).fold<int>(0, (sum, item) => sum + item.score) /
                  sectors.take(4).length)
              .round();

    final masterScore =
        ((tradeAverage * 0.65) + (sectorScore * 0.20) + (globalScore * 0.15))
            .round()
            .clamp(0, 96);

    final mode = _mode(
      masterScore: masterScore,
      tradeAverage: tradeAverage,
      sectorScore: sectorScore,
      globalScore: globalScore,
      hasCandidates: topFive.isNotEmpty,
    );

    final grade = _grade(masterScore);
    final aiDecision = _aiDecision(
      masterScore: masterScore,
      globalScore: globalScore,
      sectorScore: sectorScore,
    );
    final riskLabel = _riskLabel(globalScore);
    final leader = topFive.isEmpty ? null : topFive.first.symbol;

    return MarketMasterDecision(
      score: masterScore,
      tradeAverage: tradeAverage,
      sectorScore: sectorScore,
      globalScore: globalScore,
      mode: mode,
      grade: grade,
      aiDecision: aiDecision,
      riskLabel: riskLabel,
      comment: _comment(
        leader: leader,
        masterScore: masterScore,
        tradeAverage: tradeAverage,
        sectorScore: sectorScore,
        globalScore: globalScore,
        mode: mode,
      ),
    );
  }

  String _mode({
    required int masterScore,
    required int tradeAverage,
    required int sectorScore,
    required int globalScore,
    required bool hasCandidates,
  }) {
    if (!hasCandidates) return 'SEÇİCİ / BEKLE';
    if (globalScore <= 25) return 'TEMKİNLİ İZLE';

    if (masterScore >= 84 &&
        tradeAverage >= 84 &&
        globalScore >= 45 &&
        sectorScore >= 65) {
      return 'FIRSAT ODAKLI';
    }

    if (masterScore >= 72) return 'SEÇİCİ ALIM';
    if (masterScore >= 60) return 'TEMKİNLİ İZLE';
    return 'BEKLE';
  }

  String _grade(int score) {
    if (score >= 90) return 'A+';
    if (score >= 84) return 'A';
    if (score >= 78) return 'B+';
    if (score >= 70) return 'B';
    if (score >= 62) return 'C+';
    return 'C';
  }

  String _aiDecision({
    required int masterScore,
    required int globalScore,
    required int sectorScore,
  }) {
    if (globalScore <= 25) return 'RİSK YÜKSEK\nTEYİT BEKLE';
    if (masterScore >= 84 && sectorScore >= 75) {
      return 'GÜÇLÜ FIRSAT\nKONTROLLÜ İLERLE';
    }
    if (masterScore >= 72) return 'RİSK KONTROLLÜ\nPOZİTİF';
    if (masterScore >= 60) return 'SEÇİCİ\nTEMKİNLİ';
    return 'POZİSYON AÇMA\nBEKLE';
  }

  String _riskLabel(int globalScore) {
    if (globalScore <= 30) return 'Risk yüksek';
    if (globalScore <= 45) return 'Risk orta-yüksek';
    if (globalScore <= 65) return 'Risk orta';
    return 'Risk dengeli';
  }

  String _comment({
    required String? leader,
    required int masterScore,
    required int tradeAverage,
    required int sectorScore,
    required int globalScore,
    required String mode,
  }) {
    if (leader == null) {
      return 'CROC güvenlik filtresini geçen yeterince güçlü trade adayı yok.';
    }

    if (globalScore <= 25) {
      return '$leader teknik olarak öne çıkıyor; ancak Global Nabız $globalScore ile sert RISK OFF. Yeni işlem için teyit beklemek daha güvenli.';
    }

    if (globalScore <= 38) {
      return '$leader liderliğinde güçlü adaylar var. Global Nabız $globalScore risk iştahını sınırladığı için CROC seçici davranıyor.';
    }

    if (sectorScore >= 80 && globalScore >= 66) {
      return '$leader liderliğinde piyasa yapısı destekleyici. Sektör Nabzı $sectorScore, Global Nabız $globalScore, Master Skor $masterScore.';
    }

    return '$leader liderliğinde aday kalitesi $tradeAverage. Sektör Nabzı $sectorScore ve Global Nabız $globalScore birlikte $mode kararını destekliyor.';
  }
}
