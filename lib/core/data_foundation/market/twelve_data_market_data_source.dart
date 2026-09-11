import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/broker_environment.dart';
import 'market_data_source.dart';
import 'market_tick.dart';

class TwelveDataMarketDataSource implements MarketDataSource {
  static const String _host = 'api.twelvedata.com';
  static const Duration _sharedCacheDuration = Duration(seconds: 60);

  static final Map<String, _CachedMarketTick> _sharedCache =
      <String, _CachedMarketTick>{};

  static final Map<String, Future<MarketTick>> _inFlightRequests =
      <String, Future<MarketTick>>{};

  final http.Client _client;
  final Duration timeout;
  final Duration pollingInterval;

  TwelveDataMarketDataSource({
    http.Client? client,
    this.timeout = const Duration(seconds: 12),
    this.pollingInterval = const Duration(seconds: 60),
  }) : _client = client ?? http.Client();

  @override
  String get sourceName => 'TWELVE DATA';

  static void clearSharedCache() {
    _sharedCache.clear();
  }

  static void clearSymbolCache(String symbol) {
    _sharedCache.remove(symbol.trim().toUpperCase());
  }

  @override
  Future<MarketTick> fetchQuote(String symbol) {
    final String cacheKey = symbol.trim().toUpperCase();
    final DateTime now = DateTime.now();

    final _CachedMarketTick? cached = _sharedCache[cacheKey];

    if (cached != null &&
        now.difference(cached.savedAt) < _sharedCacheDuration) {
      return Future<MarketTick>.value(
        cached.tick.copyWith(source: '${cached.tick.source} • ÖNBELLEK'),
      );
    }

    final Future<MarketTick>? existingRequest = _inFlightRequests[cacheKey];
    if (existingRequest != null) {
      return existingRequest;
    }

    final Future<MarketTick> request = _fetchFromProvider(
      originalSymbol: symbol,
      cacheKey: cacheKey,
      staleTick: cached?.tick,
    );

    _inFlightRequests[cacheKey] = request;

    request.whenComplete(() {
      _inFlightRequests.remove(cacheKey);
    });

    return request;
  }

  Future<MarketTick> _fetchFromProvider({
    required String originalSymbol,
    required String cacheKey,
    required MarketTick? staleTick,
  }) async {
    final String apiKey = BrokerEnvironment.twelveDataApiKey.trim();

    if (apiKey.isEmpty) {
      throw const MarketDataSourceException(
        'TWELVE_DATA_API_KEY tanımlı değil. Uygulamayı '
        '--dart-define=TWELVE_DATA_API_KEY=ANAHTARINIZ ile çalıştırın.',
      );
    }

    final _ProviderRequest provider = _buildProviderRequest(originalSymbol);
    final String providerSymbol = provider.symbol;

    final Map<String, String> query = <String, String>{
      'symbol': providerSymbol,
      'interval': '1day',
      'apikey': apiKey,
      if (provider.micCode != null) 'mic_code': provider.micCode!,
    };

    final Uri uri = Uri.https(_host, '/quote', query);

    late final http.Response response;

    try {
      response = await _client.get(uri).timeout(timeout);
    } on TimeoutException {
      if (staleTick != null) {
        return staleTick.copyWith(
          timestamp: DateTime.now(),
          source: '${staleTick.source} • SON VERİ',
        );
      }

      throw const MarketDataSourceException(
        'Twelve Data isteği zaman aşımına uğradı.',
      );
    } on Object catch (error) {
      if (staleTick != null) {
        return staleTick.copyWith(
          timestamp: DateTime.now(),
          source: '${staleTick.source} • SON VERİ',
        );
      }

      throw MarketDataSourceException(
        'Twelve Data bağlantısı kurulamadı: $error',
      );
    }

    if (response.statusCode == 429 && staleTick != null) {
      return staleTick.copyWith(
        timestamp: DateTime.now(),
        source: '${staleTick.source} • LİMİTTE SON VERİ',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String detail = '';
      try {
        final Object? body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          detail = body['message']?.toString() ?? '';
        }
      } catch (_) {
        detail = '';
      }

      throw MarketDataSourceException(
        <String>[
          'Twelve Data HTTP ${response.statusCode} hatası döndürdü.',
          if (detail.trim().isNotEmpty) detail.trim(),
        ].join(' • '),
      );
    }

    final Object? decoded;

    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      if (staleTick != null) {
        return staleTick.copyWith(
          timestamp: DateTime.now(),
          source: '${staleTick.source} • SON VERİ',
        );
      }

      throw const MarketDataSourceException(
        'Twelve Data geçersiz JSON döndürdü.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const MarketDataSourceException(
        'Twelve Data yanıt biçimi beklenenden farklı.',
      );
    }

    final String? status = decoded['status']?.toString();
    final String? code = decoded['code']?.toString();
    final String? message = decoded['message']?.toString();

    if (status == 'error' || decoded.containsKey('message')) {
      if (staleTick != null) {
        return staleTick.copyWith(
          timestamp: DateTime.now(),
          source: '${staleTick.source} • SON VERİ',
        );
      }

      throw MarketDataSourceException(
        <String>[
          if (code != null && code.isNotEmpty) 'Kod $code',
          message ?? 'Twelve Data veriyi döndüremedi.',
        ].join(' • '),
      );
    }

    final double? price = _toDouble(decoded['close']);
    final double? changePercent = _toDouble(decoded['percent_change']);
    final double volume = _toDouble(decoded['volume']) ?? 0.0;

    if (price == null) {
      if (staleTick != null) {
        return staleTick.copyWith(
          timestamp: DateTime.now(),
          source: '${staleTick.source} • SON VERİ',
        );
      }

      throw MarketDataSourceException(
        '$providerSymbol için fiyat bilgisi alınamadı.',
      );
    }

    final MarketTick tick = MarketTick(
      symbol: originalSymbol,
      price: price,
      changePercent: changePercent ?? 0.0,
      volume: volume,
      timestamp: _readTimestamp(decoded),
      source: '$sourceName • $providerSymbol',
    );

    _sharedCache[cacheKey] = _CachedMarketTick(
      tick: tick,
      savedAt: DateTime.now(),
    );

    return tick;
  }

  @override
  Stream<MarketTick> watchQuote(String symbol) async* {
    while (true) {
      yield await fetchQuote(symbol);
      await Future<void>.delayed(pollingInterval);
    }
  }

  DateTime _readTimestamp(Map<String, dynamic> json) {
    final int? unix = int.tryParse(json['timestamp']?.toString() ?? '');

    if (unix != null && unix > 0) {
      return DateTime.fromMillisecondsSinceEpoch(
        unix * 1000,
        isUtc: true,
      ).toLocal();
    }

    final String? dateText = json['datetime']?.toString();

    return DateTime.tryParse(dateText ?? '') ?? DateTime.now();
  }

  double? _toDouble(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString().replaceAll(',', '.'));
  }

  _ProviderRequest _buildProviderRequest(String rawSymbol) {
    final String symbol = rawSymbol.trim().toUpperCase();

    const Map<String, String> aliases = <String, String>{
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

    final String? alias = aliases[symbol];
    if (alias != null) {
      return _ProviderRequest(symbol: alias);
    }

    // Twelve Data, Borsa İstanbul'u MIC kodu XIST ile tanımlar.
    // BIST hisselerinde "ASELS:BIST" yerine symbol=ASELS + mic_code=XIST
    // gönderiyoruz. Böylece aynı sembolün başka borsadaki karşılığıyla karışması önlenir.
    if (_looksLikeBistSymbol(symbol)) {
      return _ProviderRequest(symbol: symbol, micCode: 'XIST');
    }

    return _ProviderRequest(symbol: symbol);
  }

  bool _looksLikeBistSymbol(String symbol) {
    if (symbol == 'XU030' || symbol == 'XU100') {
      return true;
    }

    // BIST pay kodlarının büyük çoğunluğu 4-5 harfli sembollerdir.
    // Uygulamadaki hisse ekranından gelen kodlar burada XIST'e yönlendirilir.
    return RegExp(r'^[A-Z]{4,5}$').hasMatch(symbol);
  }
}

class _ProviderRequest {
  final String symbol;
  final String? micCode;

  const _ProviderRequest({required this.symbol, this.micCode});
}

class _CachedMarketTick {
  final MarketTick tick;
  final DateTime savedAt;

  const _CachedMarketTick({required this.tick, required this.savedAt});
}

class MarketDataSourceException implements Exception {
  final String message;

  const MarketDataSourceException(this.message);

  @override
  String toString() => message;
}
