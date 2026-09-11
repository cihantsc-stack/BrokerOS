import '../analysis/croc_technical_analysis.dart';
import '../data_foundation/market/yahoo_bist_market_data_source.dart';

class TechnicalSignalData {
  final String symbol;
  final int score;
  final double rsi;
  final double macd;
  final double ema20;
  final double ema50;
  final double? ema200;
  final DateTime updatedAt;
  final bool available;
  final String source;

  const TechnicalSignalData({
    required this.symbol,
    required this.score,
    required this.rsi,
    required this.macd,
    required this.ema20,
    required this.ema50,
    required this.ema200,
    required this.updatedAt,
    this.available = true,
    this.source = 'CROC Technical Engine',
  });
}

abstract interface class TechnicalProvider {
  Future<TechnicalSignalData> fetch(String symbol);
}

class CrocLiveTechnicalProvider implements TechnicalProvider {
  final YahooBistMarketDataSource source;

  final CrocTechnicalAnalysisEngine engine =
      const CrocTechnicalAnalysisEngine();

  CrocLiveTechnicalProvider({YahooBistMarketDataSource? source})
    : source = source ?? YahooBistMarketDataSource();

  @override
  Future<TechnicalSignalData> fetch(String symbol) async {
    final cleanSymbol = symbol.trim().toUpperCase().replaceAll('.IS', '');

    final snapshot = await source.fetch(
      cleanSymbol,
      range: '1y',
      interval: '1d',
    );

    final analysis = engine.analyze(snapshot.candles);

    return TechnicalSignalData(
      symbol: cleanSymbol,
      score: analysis.score,
      rsi: analysis.rsi,
      macd: analysis.macd,
      ema20: analysis.ema20,
      ema50: analysis.ema50,
      ema200: analysis.ema200,
      updatedAt: snapshot.tick.timestamp,
      available: true,
      source: 'GERCEK MUMLAR / CROC TECHNICAL ENGINE',
    );
  }
}
