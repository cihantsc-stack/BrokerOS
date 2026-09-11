import '../../engine/broker_engine.dart';
import '../../models/stock_analysis.dart';
import '../data/bist_symbol_catalog.dart';
import '../engines/ai_radar_engine.dart';
import '../models/radar_opportunity.dart';

class RadarService {
  RadarService._();

  static final RadarService instance = RadarService._();

  final AiRadarEngine _engine = const AiRadarEngine();

  List<RadarOpportunity> scan({int limit = 10}) {
    final List<StockAnalysis> source = <StockAnalysis>[...BrokerEngine.run()];

    final Set<String> existing = source
        .map((StockAnalysis item) => item.symbol.toUpperCase())
        .toSet();

    for (final String symbol in BistSymbolCatalog.companies.keys) {
      if (!existing.contains(symbol)) {
        source.add(_engine.buildSyntheticAnalysis(symbol));
      }
    }

    final List<RadarOpportunity> results = source.map(_engine.analyze).toList()
      ..sort(
        (RadarOpportunity a, RadarOpportunity b) => b.score.compareTo(a.score),
      );

    return results.take(limit).toList();
  }

  RadarOpportunity analyzeSymbol(String symbol) {
    return _engine.analyze(buildAnalysis(symbol));
  }

  StockAnalysis buildAnalysis(String symbol) {
    final String normalized = symbol.trim().toUpperCase();
    final List<StockAnalysis> analyses = BrokerEngine.run();

    for (final StockAnalysis item in analyses) {
      if (item.symbol.toUpperCase() == normalized) {
        return item;
      }
    }

    return _engine.buildSyntheticAnalysis(normalized);
  }

  List<String> searchSymbols(String query) {
    return BistSymbolCatalog.search(query).take(8).toList();
  }
}
