import 'dart:convert';
import 'dart:io';

import '../database/bist100_master_database.dart';
import '../models/bist_stock_tick.dart';

class Bist100BatchResult {
  final List<BistStockTick> ticks;
  final bool isFallback;
  final String source;
  final DateTime updatedAt;
  final List<String> failedSymbols;

  const Bist100BatchResult({
    required this.ticks,
    required this.isFallback,
    required this.source,
    required this.updatedAt,
    required this.failedSymbols,
  });
}

class Bist100BatchDataSource {
  static Bist100BatchResult? _cache;
  static DateTime? _cacheTime;
  static Future<Bist100BatchResult>? _inFlight;

  final String apiKey;
  final Duration cacheDuration;
  final int batchSize;
  final Duration batchDelay;

  const Bist100BatchDataSource({
    required this.apiKey,
    this.cacheDuration = const Duration(minutes: 15),
    this.batchSize = 8,
    this.batchDelay = const Duration(seconds: 65),
  });

  Future<Bist100BatchResult> fetch({bool forceRefresh = false}) async {
    final DateTime now = DateTime.now();

    if (!forceRefresh &&
        _cache != null &&
        _cacheTime != null &&
        now.difference(_cacheTime!) < cacheDuration) {
      return _cache!;
    }

    if (_inFlight != null) {
      return _inFlight!;
    }

    _inFlight = _fetchInternal();

    try {
      final Bist100BatchResult result = await _inFlight!;
      _cache = result;
      _cacheTime = DateTime.now();
      return result;
    } finally {
      _inFlight = null;
    }
  }

  static void clearCache() {
    _cache = null;
    _cacheTime = null;
  }

  Future<Bist100BatchResult> _fetchInternal() async {
    if (apiKey.trim().isEmpty) {
      return _fallback('API anahtarı bulunamadı');
    }

    final List<BistStockTick> ticks = <BistStockTick>[];
    final List<String> failedSymbols = <String>[];
    final List<String> symbols = Bist100MasterDatabase.symbols;

    for (int start = 0; start < symbols.length; start += batchSize) {
      final int end = (start + batchSize < symbols.length)
          ? start + batchSize
          : symbols.length;
      final List<String> batch = symbols.sublist(start, end);

      try {
        final List<BistStockTick> batchTicks = await _fetchBatch(batch);
        ticks.addAll(batchTicks);

        final Set<String> received = batchTicks
            .map((BistStockTick item) => item.stock.code)
            .toSet();

        failedSymbols.addAll(
          batch.where((String symbol) => !received.contains(symbol)),
        );
      } on _RateLimitException {
        return _mergeWithFallback(
          ticks,
          failedSymbols: <String>[...failedSymbols, ...symbols.sublist(start)],
          source: 'Twelve Data + yerel yedek (API limiti)',
        );
      } catch (_) {
        failedSymbols.addAll(batch);
      }

      if (end < symbols.length) {
        await Future<void>.delayed(batchDelay);
      }
    }

    if (ticks.isEmpty) {
      return _fallback('Canlı veri alınamadı');
    }

    return _mergeWithFallback(
      ticks,
      failedSymbols: failedSymbols,
      source: failedSymbols.isEmpty
          ? 'Twelve Data toplu veri'
          : 'Twelve Data + yerel yedek',
    );
  }

  Future<List<BistStockTick>> _fetchBatch(List<String> symbols) async {
    final HttpClient client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);

    try {
      final String encodedSymbols = symbols
          .map((String symbol) => '$symbol:BIST')
          .join(',');

      final Uri uri = Uri.https(
        'api.twelvedata.com',
        '/quote',
        <String, String>{'symbol': encodedSymbols, 'apikey': apiKey.trim()},
      );

      final HttpClientRequest request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final HttpClientResponse response = await request.close();
      final String body = await response.transform(utf8.decoder).join();

      if (response.statusCode == 429) {
        throw const _RateLimitException();
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('HTTP ${response.statusCode}');
      }

      final dynamic decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic> && decoded['status'] == 'error') {
        final int? code = _toInt(decoded['code']);
        if (code == 429) {
          throw const _RateLimitException();
        }
        throw FormatException(decoded['message']?.toString() ?? 'API hatası');
      }

      return _parseBatch(decoded);
    } finally {
      client.close(force: true);
    }
  }

  List<BistStockTick> _parseBatch(dynamic decoded) {
    final List<BistStockTick> result = <BistStockTick>[];

    if (decoded is! Map<String, dynamic>) {
      return result;
    }

    if (decoded.containsKey('symbol')) {
      final BistStockTick? single = _parseQuote(decoded);
      if (single != null) result.add(single);
      return result;
    }

    for (final MapEntry<String, dynamic> entry in decoded.entries) {
      if (entry.value is Map<String, dynamic>) {
        final Map<String, dynamic> quote = Map<String, dynamic>.from(
          entry.value as Map,
        );

        quote.putIfAbsent('symbol', () => entry.key.split(':').first);

        final BistStockTick? tick = _parseQuote(quote);
        if (tick != null) result.add(tick);
      }
    }

    return result;
  }

  BistStockTick? _parseQuote(Map<String, dynamic> quote) {
    final String rawSymbol = quote['symbol']?.toString() ?? '';
    final String symbol = rawSymbol.split(':').first.toUpperCase();
    final stock = Bist100MasterDatabase.findByCode(symbol);

    if (stock == null) return null;

    final double? price =
        _toDouble(quote['close']) ?? _toDouble(quote['price']);
    final double? change = _toDouble(quote['percent_change']);
    final double volume = _toDouble(quote['volume']) ?? 0;

    if (price == null || change == null) return null;

    return BistStockTick(
      stock: stock,
      price: price,
      changePercent: change,
      volume: volume,
    );
  }

  Bist100BatchResult _mergeWithFallback(
    List<BistStockTick> liveTicks, {
    required List<String> failedSymbols,
    required String source,
  }) {
    final Map<String, BistStockTick> bySymbol = <String, BistStockTick>{
      for (final BistStockTick tick in liveTicks) tick.stock.code: tick,
    };

    for (int index = 0; index < Bist100MasterDatabase.stocks.length; index++) {
      final stock = Bist100MasterDatabase.stocks[index];
      bySymbol.putIfAbsent(stock.code, () => _demoTick(index));
    }

    return Bist100BatchResult(
      ticks: Bist100MasterDatabase.stocks
          .map((stock) => bySymbol[stock.code]!)
          .toList(growable: false),
      isFallback: failedSymbols.isNotEmpty,
      source: source,
      updatedAt: DateTime.now(),
      failedSymbols: failedSymbols.toSet().toList(growable: false),
    );
  }

  Bist100BatchResult _fallback(String reason) {
    return Bist100BatchResult(
      ticks: List<BistStockTick>.generate(
        Bist100MasterDatabase.stocks.length,
        _demoTick,
        growable: false,
      ),
      isFallback: true,
      source: 'Yerel demo veri — $reason',
      updatedAt: DateTime.now(),
      failedSymbols: Bist100MasterDatabase.symbols,
    );
  }

  BistStockTick _demoTick(int index) {
    final stock = Bist100MasterDatabase.stocks[index];
    final int seed = stock.code.codeUnits.fold<int>(
      index + 17,
      (int value, int unit) => (value * 31 + unit) & 0x7fffffff,
    );

    final double price = 12 + ((seed % 76000) / 100);
    final double change = (((seed ~/ 13) % 900) - 400) / 100;
    final double volume = 1000000 + ((seed % 900) * 100000);

    return BistStockTick(
      stock: stock,
      price: price,
      changePercent: change,
      volume: volume,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '.'));
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class _RateLimitException implements Exception {
  const _RateLimitException();
}
