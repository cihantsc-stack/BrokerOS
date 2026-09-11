enum NewsImpact { veryPositive, positive, neutral, negative, veryNegative }

class NewsItem {
  final String title;
  final double sentiment; // -100 ... +100
  final double importance; // 0 ... 100

  const NewsItem({
    required this.title,
    required this.sentiment,
    required this.importance,
  });
}

class NewsAnalysisResult {
  final double score;
  final NewsImpact impact;
  final String summary;
  final List<String> highlights;

  const NewsAnalysisResult({
    required this.score,
    required this.impact,
    required this.summary,
    required this.highlights,
  });
}

class NewsService {
  const NewsService();

  NewsAnalysisResult analyze(List<NewsItem> news) {
    if (news.isEmpty) {
      return const NewsAnalysisResult(
        score: 50,
        impact: NewsImpact.neutral,
        summary: "Analiz edilecek haber bulunamadı.",
        highlights: [],
      );
    }

    double weighted = 0;
    double totalWeight = 0;

    for (final item in news) {
      weighted += item.sentiment * item.importance;
      totalWeight += item.importance;
    }

    final double avg = totalWeight == 0 ? 0.0 : weighted / totalWeight;

    final double score = ((avg + 100) / 2).clamp(0.0, 100.0).toDouble();

    final impact = _impact(score);

    return NewsAnalysisResult(
      score: score,
      impact: impact,
      summary: _summary(impact),
      highlights: news.take(5).map((e) => e.title).toList(),
    );
  }

  NewsImpact _impact(double score) {
    if (score >= 80) return NewsImpact.veryPositive;
    if (score >= 60) return NewsImpact.positive;
    if (score >= 40) return NewsImpact.neutral;
    if (score >= 20) return NewsImpact.negative;
    return NewsImpact.veryNegative;
  }

  String _summary(NewsImpact impact) {
    switch (impact) {
      case NewsImpact.veryPositive:
        return "Haber akışı güçlü şekilde pozitif.";
      case NewsImpact.positive:
        return "Haber akışı pozitif.";
      case NewsImpact.neutral:
        return "Haber akışı nötr.";
      case NewsImpact.negative:
        return "Haber akışı negatif.";
      case NewsImpact.veryNegative:
        return "Haber akışı güçlü şekilde negatif.";
    }
  }
}
