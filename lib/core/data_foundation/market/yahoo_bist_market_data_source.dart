import 'dart:convert';
import 'package:http/http.dart' as http;
import 'croc_data_quality.dart';
import 'historical_candle.dart';
import 'market_tick.dart';

class CrocDataIntegrityException implements Exception {
  const CrocDataIntegrityException();
}

class YahooBistSnapshot {
  final MarketTick tick;
  final List<HistoricalCandle> candles;
  final bool dataIntegrityRisk;
  final int dataQualityScore;
  final double maxPriceGapPercent;
  const YahooBistSnapshot({
    required this.tick,
    required this.candles,
    this.dataIntegrityRisk = false,
    this.dataQualityScore = 100,
    this.maxPriceGapPercent = 0,
  });
}

class YahooBistMarketDataSource {
  static const String _gatewayHost = 'croc-data-gateway.crocai.workers.dev';
  final http.Client _client;
  YahooBistMarketDataSource({http.Client? client})
    : _client = client ?? http.Client();

  Future<YahooBistSnapshot> fetch(
    String code, {
    String range = '6mo',
    String interval = '1d',
  }) async {
    final cleanCode = code.toUpperCase().replaceAll('.IS', '').trim();
    final uri = Uri.https(_gatewayHost, '/', {
      'symbol': '$cleanCode.IS',
      'range': range,
      'interval': interval,
    });
    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception(
        'CROC Data Gateway HTTP ${response.statusCode} hatası döndürdü.',
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['ok'] != true) {
      throw Exception(
        decoded is Map
            ? (decoded['error']?.toString() ?? 'Gateway veri sağlayamadı.')
            : 'Gateway yanıtı geçersiz.',
      );
    }
    final raw = decoded['candles'] as List<dynamic>? ?? const [];
    final candles = <HistoricalCandle>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;
      final ts = (item['timestamp'] as num?)?.toInt(),
          o = (item['open'] as num?)?.toDouble(),
          h = (item['high'] as num?)?.toDouble(),
          l = (item['low'] as num?)?.toDouble(),
          c = (item['close'] as num?)?.toDouble();
      if (ts == null || o == null || h == null || l == null || c == null) {
        continue;
      }
      candles.add(
        HistoricalCandle(
          time: DateTime.fromMillisecondsSinceEpoch(ts * 1000),
          open: o,
          high: h,
          low: l,
          close: c,
          volume: (item['volume'] as num?)?.toDouble() ?? 0,
        ),
      );
    }
    if (candles.isEmpty) {
      throw Exception('CROC Data Gateway mum verisi döndürmedi.');
    }
    candles.sort((a, b) => a.time.compareTo(b.time));

    final last = candles.last;
    final price = (decoded['price'] as num?)?.toDouble() ?? last.close;
    final mt = (decoded['marketTime'] as num?)?.toInt();

    // Gunluk degisim daima onceki TAMAMLANMIS seans kapanisina gore hesaplanir.
    // Gateway bazen canli fiyati bugunden getirirken mum listesini son
    // tamamlanmis gunle bitirir. Bu durumda last.close zaten onceki kapanistir.
    final marketTime = mt == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(mt * 1000);
    final dataQuality = CrocDataQualityEngine.evaluate(candles);
    final dataIntegrityRisk = dataQuality.hasRisk;
    final lastCandleTime = last.time;

    final lastCandleIsToday =
        lastCandleTime.year == marketTime.year &&
        lastCandleTime.month == marketTime.month &&
        lastCandleTime.day == marketTime.day;

    final gatewayChange = (decoded['changePercent'] as num?)?.toDouble();

    final fallbackPrev = lastCandleIsToday && candles.length > 1
        ? candles[candles.length - 2].close
        : last.close;

    final fallbackChange = fallbackPrev == 0
        ? 0.0
        : ((price - fallbackPrev) / fallbackPrev) * 100;

    // Gateway gunluk degisimi birincil kaynaktir.
    // Mum hesabi sadece gateway bu alani dondurmezse kullanilir.
    final change = gatewayChange ?? fallbackChange;
    return YahooBistSnapshot(
      tick: MarketTick(
        symbol: cleanCode,
        price: price,
        changePercent: change,
        volume: last.volume,
        timestamp: mt == null
            ? DateTime.now()
            : DateTime.fromMillisecondsSinceEpoch(mt * 1000),
        source: 'CROC DATA GATEWAY • Yahoo Finance • BIST',
      ),
      candles: candles,
      dataIntegrityRisk: dataIntegrityRisk,
      dataQualityScore: dataQuality.score,
      maxPriceGapPercent: dataQuality.maxGapPercent,
    );
  }
}
