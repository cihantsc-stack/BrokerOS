class FundIntelligenceResult {
  final bool available;
  final int score;
  final String verdict;
  final String confidence;
  final String summary;
  final List<String> strengths;
  final List<String> risks;
  final Map<String, int> layerScores;
  final List<String> unavailableLayers;

  const FundIntelligenceResult({
    required this.available,
    required this.score,
    required this.verdict,
    required this.confidence,
    required this.summary,
    required this.strengths,
    required this.risks,
    required this.layerScores,
    required this.unavailableLayers,
  });

  const FundIntelligenceResult.dataWaiting()
      : available = false,
        score = 0,
        verdict = 'VERI BEKLENIYOR',
        confidence = 'DUSUK',
        summary = 'Yeterli gercek veri olmadan CROC fon gorusu uretmez.',
        strengths = const [],
        risks = const [],
        layerScores = const {},
        unavailableLayers = const ['TEFAS'];
}
