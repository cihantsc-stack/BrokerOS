import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import '../../config/broker_environment.dart';
import 'historical_candle.dart';

class HistoricalSeriesResult {
  final List<HistoricalCandle> candles;
  final String source;
  final bool isLive;

  const HistoricalSeriesResult({
    required this.candles,
    required this.source,
    required this.isLive,
  });
}

class HistoricalMarketDataService {
  static const String _host = 'api.twelvedata.com';

  final http.Client _client;
  final Duration timeout;

  HistoricalMarketDataService({
    http.Client? client,
    this.timeout = const Duration(seconds: 12),
  }) : _client = client ?? http.Client();

  Future<HistoricalSeriesResult> fetch({
    required String symbol,
    required String interval,
    required int outputSize,
    required double fallbackPrice,
  }) async {
    final apiKey = BrokerEnvironment.twelveDataApiKey.trim();
    if (apiKey.isEmpty) {
      return _fallback(
        symbol,
        outputSize,
        fallbackPrice,
        'SİMÜLASYON • API ANAHTARI YOK',
      );
    }

    final providerSymbol = _normalizeSymbol(symbol);
    final uri = Uri.https(_host, '/time_series', <String, String>{
      'symbol': providerSymbol,
      'interval': interval,
      'outputsize': outputSize.toString(),
      'order': 'ASC',
      'apikey': apiKey,
    });

    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _fallback(
          symbol,
          outputSize,
          fallbackPrice,
          'SİMÜLASYON • HTTP ${response.statusCode}',
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['values'] is! List) {
        return _fallback(
          symbol,
          outputSize,
          fallbackPrice,
          'SİMÜLASYON • VERİ YOK',
        );
      }
      final values = decoded['values'] as List<dynamic>;
      final candles = values
          .whereType<Map<String, dynamic>>()
          .map((row) {
            return HistoricalCandle(
              time:
                  DateTime.tryParse(row['datetime']?.toString() ?? '') ??
                  DateTime.now(),
              open: _toDouble(row['open']),
              high: _toDouble(row['high']),
              low: _toDouble(row['low']),
              close: _toDouble(row['close']),
              volume: _toDouble(row['volume']),
            );
          })
          .where((c) => c.open > 0 && c.high > 0 && c.low > 0 && c.close > 0)
          .toList();

      if (candles.length < 12) {
        return _fallback(
          symbol,
          outputSize,
          fallbackPrice,
          'SİMÜLASYON • EKSİK SERİ',
        );
      }

      final maxVolume = candles.map((c) => c.volume).fold<double>(0, math.max);
      final normalized = candles
          .map(
            (c) => HistoricalCandle(
              time: c.time,
              open: c.open,
              high: c.high,
              low: c.low,
              close: c.close,
              volume: maxVolume <= 0
                  ? 0.3
                  : (c.volume / maxVolume).clamp(0.06, 1.0).toDouble(),
            ),
          )
          .toList();

      return HistoricalSeriesResult(
        candles: normalized,
        source: 'TWELVE DATA • $providerSymbol • $interval',
        isLive: true,
      );
    } catch (_) {
      return _fallback(
        symbol,
        outputSize,
        fallbackPrice,
        'SİMÜLASYON • BAĞLANTI YEDEĞİ',
      );
    }
  }

  HistoricalSeriesResult _fallback(
    String symbol,
    int count,
    double price,
    String source,
  ) {
    final seed = symbol.codeUnits.fold<int>(17, (a, b) => a * 37 + b);
    final random = math.Random(seed + count);
    final candles = <HistoricalCandle>[];
    var previous = price * (0.88 + (seed.abs() % 8) / 100);
    for (var i = 0; i < count; i++) {
      final drift = ((seed % 9) - 3) / 10000;
      final wave = math.sin(i * 0.31 + seed) * 0.006;
      final shock = (random.nextDouble() - 0.5) * 0.016;
      final open = previous;
      var close = open * (1 + drift + wave + shock);
      if (i == count - 1) close = price;
      final wick = close * (0.003 + random.nextDouble() * 0.009);
      final high = math.max(open, close) + wick;
      final low = math.min(open, close) - wick;
      candles.add(
        HistoricalCandle(
          time: DateTime.now().subtract(Duration(days: count - i)),
          open: open,
          high: high,
          low: low,
          close: close,
          volume: (0.15 + random.nextDouble() * 0.75)
              .clamp(0.06, 1.0)
              .toDouble(),
        ),
      );
      previous = close;
    }
    return HistoricalSeriesResult(
      candles: candles,
      source: source,
      isLive: false,
    );
  }

  String _normalizeSymbol(String raw) {
    final symbol = raw.trim().toUpperCase();
    const aliases = <String, String>{
      'USDTRY': 'USD/TRY',
      'EURTRY': 'EUR/TRY',
      'BTCUSD': 'BTC/USD',
      'BTCUSDT': 'BTC/USDT',
      'ETHUSD': 'ETH/USD',
      'ETHUSDT': 'ETH/USDT',
      'XAUUSD': 'XAU/USD',
      'ONSALTIN': 'XAU/USD',
      'GRAMALTIN': 'XAU/TRY',
    };
    if (aliases.containsKey(symbol)) return aliases[symbol]!;
    if (RegExp(r'^[A-Z0-9]{4,6}$').hasMatch(symbol)) return '$symbol:BIST';
    return symbol;
  }

  double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().replaceAll(',', '.') ?? '') ?? 0;
  }
}
