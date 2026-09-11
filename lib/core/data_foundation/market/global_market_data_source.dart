import 'dart:convert';

import 'package:http/http.dart' as http;

class GlobalMarketQuote {
  final String symbol;
  final double price;
  final double previousClose;
  final double changePercent;
  final DateTime? marketTime;

  const GlobalMarketQuote({
    required this.symbol,
    required this.price,
    required this.previousClose,
    required this.changePercent,
    required this.marketTime,
  });
}

class GlobalMarketDataSource {
  static const String _gatewayHost = 'croc-data-gateway.crocai.workers.dev';

  final http.Client _client;

  GlobalMarketDataSource({http.Client? client})
    : _client = client ?? http.Client();

  Future<GlobalMarketQuote> fetch(String symbol) async {
    final cleanSymbol = symbol.trim();

    if (cleanSymbol.isEmpty) {
      throw Exception('Piyasa sembolü boş olamaz.');
    }

    final uri = Uri.https(_gatewayHost, '/', {
      'symbol': cleanSymbol,
      'range': '5d',
      'interval': '1d',
    });

    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'CROC Gateway HTTP ${response.statusCode} - $cleanSymbol',
      );
    }

    final dynamic decodedRaw = jsonDecode(response.body);

    if (decodedRaw is! Map) {
      throw Exception('$cleanSymbol için geçersiz gateway yanıtı.');
    }

    final decoded = Map<String, dynamic>.from(decodedRaw);

    if (decoded['ok'] != true) {
      final error =
          decoded['error']?.toString() ?? '$cleanSymbol verisi alınamadı.';

      throw Exception(error);
    }

    final price = _toDouble(decoded['price']);
    final gatewayPreviousClose = _toDouble(decoded['previousClose']);

    // 5d/1d Gateway previousClose bazen pencerenin ilk kapanisi oluyor.
    // Gunluk degisim icin bugunku mumdan onceki son gecerli kapanisi kullan.
    double? previousClose;
    final rawCandles = decoded['candles'];

    if (rawCandles is List && rawCandles.length >= 2) {
      for (var i = rawCandles.length - 2; i >= 0; i--) {
        final row = rawCandles[i];
        if (row is Map) {
          final close = _toDouble(row['close']);
          if (close != null && close > 0) {
            previousClose = close;
            break;
          }
        }
      }
    }

    previousClose ??= gatewayPreviousClose;

    if (price == null) {
      throw Exception('$cleanSymbol güncel fiyatı alınamadı.');
    }

    if (previousClose == null) {
      throw Exception('$cleanSymbol önceki kapanışı alınamadı.');
    }

    final changePercent = previousClose == 0
        ? 0.0
        : ((price - previousClose) / previousClose) * 100;

    final marketTimestamp = _toInt(decoded['marketTime']);

    return GlobalMarketQuote(
      symbol: decoded['symbol']?.toString() ?? cleanSymbol,
      price: price,
      previousClose: previousClose,
      changePercent: changePercent,
      marketTime: marketTimestamp == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(marketTimestamp * 1000),
    );
  }

  double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.').trim());
    }

    return null;
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim());
    }

    return null;
  }
}
