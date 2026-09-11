import '../../../core/data_foundation/market/yahoo_bist_market_data_source.dart';
import '../models/data_terminal_quote.dart';

class DataTerminalService {
  final YahooBistMarketDataSource _source;

  DataTerminalService({YahooBistMarketDataSource? source})
    : _source = source ?? YahooBistMarketDataSource();

  Future<DataTerminalQuote?> fetchQuote(String code, {String? company}) async {
    final cleanCode = code.trim().toUpperCase().replaceAll('.IS', '');

    if (cleanCode.isEmpty) {
      return null;
    }

    try {
      final snapshot = await _source.fetch(
        cleanCode,
        range: '5d',
        interval: '1d',
      );

      return DataTerminalQuote(
        code: cleanCode,
        company: company ?? '$cleanCode • Borsa İstanbul',
        tick: snapshot.tick,
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<DataTerminalQuote>> fetchQuotes(
    List<MapEntry<String, String>> symbols, {
    int concurrency = 6,
  }) async {
    final results = <DataTerminalQuote>[];

    for (var i = 0; i < symbols.length; i += concurrency) {
      final batch = symbols.skip(i).take(concurrency).toList();

      final rows = await Future.wait(
        batch.map((entry) async {
          try {
            final snapshot = await _source.fetch(
              entry.key,
              range: '5d',
              interval: '1d',
            );

            return DataTerminalQuote(
              code: entry.key,
              company: entry.value,
              tick: snapshot.tick,
            );
          } catch (_) {
            return null;
          }
        }),
      );

      results.addAll(rows.whereType<DataTerminalQuote>());
    }

    return results;
  }
}
