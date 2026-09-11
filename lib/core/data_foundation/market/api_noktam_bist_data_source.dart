import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/broker_environment.dart';
import 'market_data_source.dart';
import 'market_tick.dart';

/// BIST quote adapter for api.apinoktam.erenozdemir.com.tr.
/// Uses the authenticated endpoint when APINOKTAM_API_KEY is supplied,
/// otherwise uses the provider's public test endpoint.
class ApiNoktamBistDataSource implements MarketDataSource {
  static const String _host = 'api.apinoktam.erenozdemir.com.tr';
  final http.Client _client;
  final Duration timeout;
  final Duration pollingInterval;

  ApiNoktamBistDataSource({
    http.Client? client,
    this.timeout = const Duration(seconds: 12),
    this.pollingInterval = const Duration(seconds: 60),
  }) : _client = client ?? http.Client();

  @override
  String get sourceName => 'API NOKTAM • BIST';

  @override
  Future<MarketTick> fetchQuote(String rawSymbol) async {
    final symbol = _cleanSymbol(rawSymbol);
    final apiKey = BrokerEnvironment.apiNoktamApiKey.trim();

    // Public test endpoint is documented as /public/v1/bist.  The paid/keyed
    // route also has a symbol detail endpoint.  Public mode fetches the list
    // once and finds the requested symbol locally.
    final bool authenticated = apiKey.isNotEmpty;
    final Uri uri = authenticated
        ? Uri.https(_host, '/v1/bist/$symbol')
        : Uri.https(_host, '/public/v1/bist');

    late http.Response response;
    try {
      response = await _client
          .get(uri, headers: authenticated ? {'x-api-key': apiKey} : null)
          .timeout(timeout);
    } on TimeoutException {
      throw const ApiNoktamException('API Noktam isteği zaman aşımına uğradı.');
    } catch (e) {
      throw ApiNoktamException('API Noktam bağlantısı kurulamadı: $e');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiNoktamException(
        'API Noktam HTTP ${response.statusCode} hatası döndürdü.',
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw const ApiNoktamException('API Noktam geçersiz JSON döndürdü.');
    }

    final Map<String, dynamic>? row = authenticated
        ? _extractSingle(decoded, symbol)
        : _findSymbol(decoded, symbol);

    if (row == null) {
      throw ApiNoktamException('$symbol API Noktam BIST yanıtında bulunamadı.');
    }

    final price = _firstNumber(row, const [
      'price',
      'last',
      'lastPrice',
      'last_price',
      'close',
      'kapanis',
      'kapanış',
      'son',
      'sonFiyat',
      'son_fiyat',
      'currentPrice',
      'current_price',
    ]);
    final change =
        _firstNumber(row, const [
          'changePercent',
          'change_percent',
          'percentChange',
          'percent_change',
          'changeRate',
          'change_rate',
          'degisim',
          'değişim',
          'yuzdeDegisim',
          'yuzde_degisim',
          'percentage',
        ]) ??
        0.0;
    final volume =
        _firstNumber(row, const [
          'volume',
          'hacim',
          'totalVolume',
          'total_volume',
        ]) ??
        0.0;

    if (price == null || price <= 0) {
      throw ApiNoktamException(
        '$symbol bulundu fakat fiyat alanı okunamadı. Gelen alanlar: ${row.keys.take(12).join(', ')}',
      );
    }

    return MarketTick(
      symbol: symbol,
      price: price,
      changePercent: change,
      volume: volume,
      timestamp: DateTime.now(),
      source: '$sourceName • $symbol${authenticated ? ' • KEY' : ' • TEST'}',
    );
  }

  @override
  Stream<MarketTick> watchQuote(String symbol) async* {
    while (true) {
      yield await fetchQuote(symbol);
      await Future<void>.delayed(pollingInterval);
    }
  }

  String _cleanSymbol(String raw) =>
      raw.trim().toUpperCase().replaceAll(':BIST', '').replaceAll('.IS', '');

  Map<String, dynamic>? _extractSingle(dynamic node, String symbol) {
    if (node is Map<String, dynamic>) {
      final directSymbol = _symbolOf(node);
      if (directSymbol == null || directSymbol == symbol) {
        if (_looksLikeQuote(node)) return node;
      }
      for (final value in node.values) {
        final found = _extractSingle(value, symbol);
        if (found != null) return found;
      }
    } else if (node is List) {
      for (final value in node) {
        final found = _extractSingle(value, symbol);
        if (found != null) return found;
      }
    }
    return null;
  }

  Map<String, dynamic>? _findSymbol(dynamic node, String symbol) {
    if (node is Map<String, dynamic>) {
      if (_symbolOf(node) == symbol) return node;
      for (final value in node.values) {
        final found = _findSymbol(value, symbol);
        if (found != null) return found;
      }
    } else if (node is List) {
      for (final value in node) {
        final found = _findSymbol(value, symbol);
        if (found != null) return found;
      }
    }
    return null;
  }

  String? _symbolOf(Map<String, dynamic> row) {
    for (final key in const ['symbol', 'sembol', 'code', 'kod', 'ticker']) {
      final value = row[key]?.toString().trim().toUpperCase();
      if (value != null && value.isNotEmpty) {
        return value.replaceAll('.IS', '').replaceAll(':BIST', '');
      }
    }
    return null;
  }

  bool _looksLikeQuote(Map<String, dynamic> row) =>
      _firstNumber(row, const [
        'price',
        'last',
        'lastPrice',
        'close',
        'son',
        'kapanis',
        'kapanış',
      ]) !=
      null;

  double? _firstNumber(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      if (!row.containsKey(key)) continue;
      final value = _toDouble(row[key]);
      if (value != null) return value;
    }
    return null;
  }

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value == null) return null;
    var text = value.toString().trim().replaceAll('%', '').replaceAll('₺', '');
    if (text.contains(',') && text.contains('.')) {
      text = text.replaceAll('.', '').replaceAll(',', '.');
    } else {
      text = text.replaceAll(',', '.');
    }
    return double.tryParse(text);
  }
}

class ApiNoktamException implements Exception {
  final String message;
  const ApiNoktamException(this.message);
  @override
  String toString() => message;
}
