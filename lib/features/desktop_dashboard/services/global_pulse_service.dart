import '../../../core/data_foundation/market/global_market_data_source.dart';

class GlobalPulseItem {
  final String key;
  final String label;
  final double changePercent;
  final bool inverse;

  const GlobalPulseItem({
    required this.key,
    required this.label,
    required this.changePercent,
    this.inverse = false,
  });

  double get contribution {
    final raw = changePercent.clamp(-3.0, 3.0) / 3.0;
    return inverse ? -raw : raw;
  }
}

class GlobalPulseSnapshot {
  final int score;
  final String regime;
  final String comment;
  final List<GlobalPulseItem> items;
  final DateTime calculatedAt;

  const GlobalPulseSnapshot({
    required this.score,
    required this.regime,
    required this.comment,
    required this.items,
    required this.calculatedAt,
  });
}

class GlobalPulseService {
  GlobalPulseService._();

  static final GlobalPulseService instance = GlobalPulseService._();

  final GlobalMarketDataSource _source = GlobalMarketDataSource();

  GlobalPulseSnapshot? _cache;
  DateTime? _cacheTime;

  static const Map<String, String> _symbols = {
    'sp500': '^GSPC',
    'nasdaq': '^IXIC',
    'dow': '^DJI',
    'dax': '^GDAXI',
    'nikkei': '^N225',
    'vix': '^VIX',
    'brent': 'BZ=F',
    'gold': 'GC=F',
  };

  Future<GlobalPulseSnapshot> fetch({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cache != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < const Duration(minutes: 5)) {
      return _cache!;
    }

    final rows = await Future.wait(
      _symbols.entries.map((entry) async {
        try {
          final quote = await _source.fetch(entry.value);
          return MapEntry(entry.key, quote.changePercent);
        } catch (_) {
          return MapEntry<String, double?>(entry.key, null);
        }
      }),
    );

    final map = <String, double>{};

    for (final row in rows) {
      final value = row.value;
      if (value != null) {
        map[row.key] = value;
      }
    }

    final items = <GlobalPulseItem>[
      if (map['sp500'] != null)
        GlobalPulseItem(
          key: 'sp500',
          label: 'S&P 500',
          changePercent: map['sp500']!,
        ),
      if (map['nasdaq'] != null)
        GlobalPulseItem(
          key: 'nasdaq',
          label: 'Nasdaq',
          changePercent: map['nasdaq']!,
        ),
      if (map['dow'] != null)
        GlobalPulseItem(key: 'dow', label: 'Dow', changePercent: map['dow']!),
      if (map['dax'] != null)
        GlobalPulseItem(key: 'dax', label: 'DAX', changePercent: map['dax']!),
      if (map['nikkei'] != null)
        GlobalPulseItem(
          key: 'nikkei',
          label: 'Nikkei',
          changePercent: map['nikkei']!,
        ),
      if (map['vix'] != null)
        GlobalPulseItem(
          key: 'vix',
          label: 'VIX',
          changePercent: map['vix']!,
          inverse: true,
        ),
      if (map['brent'] != null)
        GlobalPulseItem(
          key: 'brent',
          label: 'Brent',
          changePercent: map['brent']!,
          inverse: true,
        ),
      if (map['gold'] != null)
        GlobalPulseItem(
          key: 'gold',
          label: 'Altın',
          changePercent: map['gold']!,
          inverse: true,
        ),
    ];

    if (items.isEmpty) {
      throw Exception('Global piyasa verisi alınamadı.');
    }

    final weighted = _weightedScore(items);
    final score = weighted.round().clamp(5, 95);

    final regime = score >= 72
        ? 'RISK ON'
        : score <= 38
        ? 'RISK OFF'
        : 'NÖTR';

    final comment = score >= 72
        ? 'Global ortam risk iştahını destekliyor.'
        : score <= 38
        ? 'Global ortam temkinli; risk iştahı zayıf.'
        : 'Global görünüm dengeli, seçici hareket uygun.';

    final snapshot = GlobalPulseSnapshot(
      score: score,
      regime: regime,
      comment: comment,
      items: items,
      calculatedAt: DateTime.now(),
    );

    _cache = snapshot;
    _cacheTime = DateTime.now();

    return snapshot;
  }

  double _weightedScore(List<GlobalPulseItem> items) {
    var score = 50.0;
    var usedWeight = 0.0;

    for (final item in items) {
      final weight = switch (item.key) {
        'sp500' => 13.0,
        'nasdaq' => 13.0,
        'dow' => 8.0,
        'dax' => 9.0,
        'nikkei' => 7.0,
        'vix' => 18.0,
        'brent' => 7.0,
        'gold' => 5.0,
        _ => 0.0,
      };

      score += item.contribution * weight;
      usedWeight += weight;
    }

    if (usedWeight == 0) return 50;

    // Eksik veri olduğunda aşırı skora gitmesini engelle.
    final coverage = (usedWeight / 80.0).clamp(0.35, 1.0);
    return 50 + ((score - 50) * coverage);
  }

  void clearCache() {
    _cache = null;
    _cacheTime = null;
  }
}
