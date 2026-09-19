import '../../data_foundation/market/yahoo_bist_market_data_source.dart';
import 'bist_universe_service.dart';

class CrocBistTradableMember {
  final String id;
  final String code;
  final String title;

  const CrocBistTradableMember({
    required this.id,
    required this.code,
    required this.title,
  });
}

class CrocBistTradableUniverse {
  CrocBistTradableUniverse({
    BistUniverseService? universeService,
    YahooBistMarketDataSource? marketDataSource,
  }) : _universeService = universeService ?? BistUniverseService(),
       _marketDataSource = marketDataSource ?? YahooBistMarketDataSource();

  final BistUniverseService _universeService;
  final YahooBistMarketDataSource _marketDataSource;

  static List<CrocBistTradableMember>? _cache;
  static DateTime? _cacheTime;

  /// Merkezi islem gorebilir BIST evrenini getirir.
  ///
  /// KAP aktif sirket/kod evreni kaynak olarak kullanilir.
  /// Yahoo'dan gercek piyasa verisi alinabilen kodlar tutulur.
  Future<List<CrocBistTradableMember>> fetch({
    Duration ttl = const Duration(hours: 6),
    bool forceRefresh = false,
  }) async {
    final universeTotalWatch = Stopwatch()..start();

    if (!forceRefresh &&
        _cache != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < ttl) {
      return _cache!;
    }

    final kapWatch = Stopwatch()..start();

    final kapMembers = await _universeService.fetchActiveCandidates(
      ttl: forceRefresh ? Duration.zero : const Duration(minutes: 30),
    );

    kapWatch.stop();

    print(
      'CROC UNIVERSE TIMING | KAP LISTESI | '
      '${(kapWatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} SN | '
      '${kapMembers.length} KOD',
    );

    final validationWatch = Stopwatch()..start();

    final result = <CrocBistTradableMember>[];
    final seen = <String>{};

    // CROC BIST UNIVERSE PARALLEL VALIDATION
    // Yahoo tradable kontrolleri kontrollu batch'ler halinde paralel calisir.
    const validationConcurrency = 20;

    final uniqueMembers = <({dynamic member, String code})>[];

    for (final member in kapMembers) {
      final code = member.stockCode.trim().toUpperCase();

      if (code.isEmpty || !seen.add(code)) {
        continue;
      }

      uniqueMembers.add((member: member, code: code));
    }

    for (var i = 0; i < uniqueMembers.length; i += validationConcurrency) {
      final batch = uniqueMembers
          .skip(i)
          .take(validationConcurrency)
          .toList(growable: false);

      final validated = await Future.wait(
        batch.map((item) async {
          try {
            final snapshot = await _marketDataSource.fetch(
              item.code,
              range: '5d',
              interval: '1d',
            );

            if (snapshot.candles.isEmpty || snapshot.tick.price <= 0) {
              return null;
            }

            return CrocBistTradableMember(
              id: item.member.id,
              code: item.code,
              title: item.member.title,
            );
          } catch (_) {
            // Yahoo'da piyasa verisi olmayan KAP kodlari
            // merkezi pay evrenine alinmaz.
            return null;
          }
        }),
      );

      result.addAll(validated.whereType<CrocBistTradableMember>());
    }

    result.sort((a, b) => a.code.compareTo(b.code));

    validationWatch.stop();

    print(
      'CROC UNIVERSE TIMING | YAHOO VALIDATION | '
      '${(validationWatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} SN | '
      '${result.length} GECERLI HISSE',
    );

    _cache = List<CrocBistTradableMember>.unmodifiable(result);
    _cacheTime = DateTime.now();

    universeTotalWatch.stop();

    print(
      'CROC UNIVERSE TIMING | TOTAL | '
      '${(universeTotalWatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} SN',
    );

    return _cache!;
  }

  /// Cache'i temizler.
  /// Yeni halka arz / sembol degisikligi gibi durumlarda
  /// zorunlu yenileme icin kullanilabilir.
  static void clearCache() {
    _cache = null;
    _cacheTime = null;
  }

  /// Mevcut cache.
  /// Cache henuz olusmadiysa bos liste doner.
  static List<CrocBistTradableMember> get cached =>
      _cache ?? const <CrocBistTradableMember>[];

  /// Cache icinde kod var mi?
  static bool containsCached(String symbol) {
    final code = symbol.trim().toUpperCase();

    return cached.any((item) => item.code == code);
  }

  /// Cache icinden sirket adi.
  static String companyOfCached(String symbol) {
    final code = symbol.trim().toUpperCase();

    for (final item in cached) {
      if (item.code == code) {
        return item.title;
      }
    }

    return '$code Hissesi';
  }
}
