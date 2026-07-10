class MarketNews {
  final String title;
  final String source;
  final DateTime publishedAt;
  final int sentimentScore;
  final String impact;
  final List<String> relatedSymbols;

  const MarketNews({
    required this.title,
    required this.source,
    required this.publishedAt,
    required this.sentimentScore,
    required this.impact,
    required this.relatedSymbols,
  });
}