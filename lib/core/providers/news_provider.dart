import 'dart:convert';

import 'package:http/http.dart' as http;

class NewsSignalData {
  final String symbol;
  final int score;
  final String sentiment;
  final List<String> headlines;
  final DateTime updatedAt;
  final bool available;
  final String status;

  const NewsSignalData({
    required this.symbol,
    required this.score,
    required this.sentiment,
    required this.headlines,
    required this.updatedAt,
    this.available = false,
    this.status = 'Haber veri kaynağı bekleniyor',
  });
}

abstract interface class NewsProvider {
  Future<NewsSignalData> fetch(String symbol);
}

// ============================================================
// CROC V39 - CANLI HABER PROVIDER
// Cloudflare CROC Data Gateway üzerinden çalışır.
// ============================================================

class CrocLiveNewsProvider implements NewsProvider {
  static const String _gatewayHost = 'croc-data-gateway.crocai.workers.dev';

  final http.Client _client;

  CrocLiveNewsProvider({http.Client? client})
    : _client = client ?? http.Client();

  @override
  Future<NewsSignalData> fetch(String symbol) async {
    final cleanSymbol = symbol.trim().toUpperCase().replaceAll('.IS', '');

    final uri = Uri.https(_gatewayHost, '/', <String, String>{
      'mode': 'news',
      'symbol': '$cleanSymbol.IS',
    });

    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return _unavailable(
          cleanSymbol,
          'Haber Gateway HTTP ${response.statusCode}',
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return _unavailable(cleanSymbol, 'Haber Gateway yanıtı geçersiz');
      }

      if (decoded['ok'] != true) {
        return _unavailable(
          cleanSymbol,
          decoded['error']?.toString() ??
              decoded['status']?.toString() ??
              'Haber verisi alınamadı',
        );
      }

      final bool available = decoded['available'] == true;

      final int score = _readScore(decoded['score']);

      final String sentiment =
          decoded['sentiment']?.toString() ??
          (available ? 'NÖTR' : 'VERİ BEKLENİYOR');

      final String status =
          decoded['status']?.toString() ??
          (available ? 'Canlı haber verisi alındı' : 'Haber verisi bekleniyor');

      final List<String> headlines = _readHeadlines(decoded['headlines']);

      final DateTime updatedAt = _readUpdatedAt(decoded['updatedAt']);

      return NewsSignalData(
        symbol: cleanSymbol,
        score: available ? score : 0,
        sentiment: sentiment,
        headlines: headlines,
        updatedAt: updatedAt,
        available: available,
        status: status,
      );
    } catch (error) {
      return _unavailable(cleanSymbol, 'Haber bağlantısı kurulamadı: $error');
    }
  }

  static int _readScore(dynamic value) {
    if (value is num) {
      return value.round().clamp(0, 100);
    }

    return int.tryParse(value?.toString() ?? '')?.clamp(0, 100) ?? 0;
  }

  static List<String> _readHeadlines(dynamic value) {
    if (value is! List) {
      return const <String>[];
    }

    final List<String> result = <String>[];

    for (final dynamic item in value) {
      if (item is Map) {
        final dynamic rawTitle = item['title'];

        final String title = rawTitle?.toString().trim() ?? '';

        if (title.isNotEmpty) {
          result.add(title);
        }

        continue;
      }

      final String title = item?.toString().trim() ?? '';

      if (title.isNotEmpty) {
        result.add(title);
      }
    }

    return List<String>.unmodifiable(result);
  }

  static DateTime _readUpdatedAt(dynamic value) {
    final String raw = value?.toString() ?? '';

    return DateTime.tryParse(raw) ?? DateTime.now();
  }

  static NewsSignalData _unavailable(String symbol, String status) {
    return NewsSignalData(
      symbol: symbol,
      score: 0,
      sentiment: 'VERİ BEKLENİYOR',
      headlines: const <String>[],
      updatedAt: DateTime.now(),
      available: false,
      status: status,
    );
  }
}

// ============================================================
// FALLBACK PROVIDER
// ============================================================

class UnavailableNewsProvider implements NewsProvider {
  const UnavailableNewsProvider();

  @override
  Future<NewsSignalData> fetch(String symbol) async {
    return NewsSignalData(
      symbol: symbol.trim().toUpperCase().replaceAll('.IS', ''),
      score: 0,
      sentiment: 'VERİ BEKLENİYOR',
      headlines: const <String>[],
      updatedAt: DateTime.now(),
      available: false,
      status: 'GERÇEK HABER MOTORU BEKLENİYOR',
    );
  }
}
