import 'dart:convert';

import 'package:http/http.dart' as http;

class KapIntelligenceResult {
  final String symbol;
  final int score;
  final String sentiment;
  final String importance;
  final List<String> eventTypes;
  final List<String> reasons;
  final String summary;
  final String disclosureIndex;
  final String time;
  final String link;

  const KapIntelligenceResult({
    required this.symbol,
    required this.score,
    required this.sentiment,
    required this.importance,
    required this.eventTypes,
    required this.reasons,
    required this.summary,
    required this.disclosureIndex,
    required this.time,
    required this.link,
  });

  bool get hasData => disclosureIndex.isNotEmpty;

  static const empty = KapIntelligenceResult(
    symbol: '',
    score: 0,
    sentiment: 'VERİ YOK',
    importance: 'VERİ YOK',
    eventTypes: [],
    reasons: [],
    summary: '',
    disclosureIndex: '',
    time: '',
    link: '',
  );
}

class KapIntelligenceService {
  KapIntelligenceService._();

  static final KapIntelligenceService instance = KapIntelligenceService._();

  static const String _base = 'https://croc-data-gateway.crocai.workers.dev/';

  final Map<String, String> _symbolToCompanyId = {};
  final Map<String, KapIntelligenceResult> _cache = {};

  bool _membersLoaded = false;

  Future<KapIntelligenceResult> analyzeSymbol(String rawSymbol) async {
    final symbol = _normalizeSymbol(rawSymbol);

    if (symbol.isEmpty) {
      return KapIntelligenceResult.empty;
    }

    final cached = _cache[symbol];

    if (cached != null) {
      return cached;
    }

    await _ensureMembers();

    final companyId = _symbolToCompanyId[symbol];

    if (companyId == null || companyId.isEmpty) {
      return KapIntelligenceResult.empty;
    }

    final status = await _getJson(Uri.parse('$_base?mode=kap&action=status'));

    final lastIndex =
        int.tryParse(status['lastDisclosureIndex']?.toString() ?? '') ?? 0;

    if (lastIndex <= 0) {
      return KapIntelligenceResult.empty;
    }

    //
    // Dinamik KAP tarama penceresi.
    // Önce yakın bildirimleri kontrol eder, gerekirse geriye doğru genişler.
    //
    List<Map<String, dynamic>> companyItems = const [];

    const windows = <int>[250, 1000, 3000];

    for (final window in windows) {
      final from = (lastIndex - (window - 1)).clamp(1, lastIndex);

      final feed = await _getJson(
        Uri.parse('$_base?mode=kap&action=feed&from=$from'),
      );

      final rawItems = feed['items'] is List ? feed['items'] as List : const [];

      final matches = rawItems
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .where((item) {
            return item['companyId']?.toString() == companyId &&
                item['disclosureClass']?.toString().toUpperCase() == 'ODA' &&
                item['fundId'] == null &&
                item['fundCode'] == null;
          })
          .toList();

      if (matches.isNotEmpty) {
        companyItems = matches;
        break;
      }
    }

    companyItems.sort((a, b) {
      final ai = int.tryParse(a['disclosureIndex']?.toString() ?? '') ?? 0;
      final bi = int.tryParse(b['disclosureIndex']?.toString() ?? '') ?? 0;

      return bi.compareTo(ai);
    });

    if (companyItems.isEmpty) {
      return KapIntelligenceResult.empty;
    }

    //
    // En yeni gerçek şirket KAP bildirimi.
    //
    final item = companyItems.first;

    final disclosureIndex = item['disclosureIndex']?.toString() ?? '';

    if (disclosureIndex.isEmpty) {
      return KapIntelligenceResult.empty;
    }

    final reports = item['subReportIds'] is List
        ? item['subReportIds'] as List
        : const [];

    final subReport = reports.isNotEmpty ? reports.first.toString() : '';

    final params = <String, String>{
      'mode': 'kap',
      'action': 'detail',
      'index': disclosureIndex,
      'fileType': 'html',
    };

    if (subReport.isNotEmpty) {
      params['subReport'] = subReport;
    }

    final detail = await _getJson(
      Uri.parse(_base).replace(queryParameters: params),
    );

    final impactRaw = detail['impact'];

    final impact = impactRaw is Map
        ? Map<String, dynamic>.from(impactRaw)
        : <String, dynamic>{};

    final result = KapIntelligenceResult(
      symbol: _normalizeSymbol(detail['symbol']?.toString() ?? symbol),
      score: _parseScore(impact['score']),
      sentiment: impact['sentiment']?.toString().trim().isNotEmpty == true
          ? impact['sentiment'].toString()
          : 'NÖTR',
      importance: impact['importance']?.toString().trim().isNotEmpty == true
          ? impact['importance'].toString()
          : 'BİLİNMİYOR',
      eventTypes: _stringList(impact['eventTypes']),
      reasons: _stringList(impact['reasons']),
      summary: detail['summary']?.toString() ?? '',
      disclosureIndex: disclosureIndex,
      time: detail['time']?.toString() ?? '',
      link: detail['link']?.toString() ?? '',
    );

    _cache[symbol] = result;

    return result;
  }

  Future<void> _ensureMembers() async {
    if (_membersLoaded) {
      return;
    }

    final response = await _getJson(
      Uri.parse('$_base?mode=kap&action=members'),
    );

    final members = response['members'] is List
        ? response['members'] as List
        : const [];

    for (final raw in members) {
      if (raw is! Map) {
        continue;
      }

      final member = Map<String, dynamic>.from(raw);

      final companyId = member['id']?.toString().trim() ?? '';
      final stockCode = member['stockCode']?.toString().trim() ?? '';

      if (companyId.isEmpty || stockCode.isEmpty) {
        continue;
      }

      //
      // Bazı KAP üyelerinde:
      // "A1CAP, ACP"
      // gibi birden fazla kod bulunabiliyor.
      //
      for (final rawCode in stockCode.split(',')) {
        final code = _normalizeSymbol(rawCode);

        if (code.isEmpty) {
          continue;
        }

        _symbolToCompanyId.putIfAbsent(code, () => companyId);
      }
    }

    _membersLoaded = true;
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await http
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('KAP Gateway HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is! Map) {
      throw Exception('KAP Gateway geçersiz cevap döndürdü.');
    }

    final result = Map<String, dynamic>.from(decoded);

    if (result['ok'] == false) {
      throw Exception(
        result['error']?.toString() ?? 'KAP Gateway isteği başarısız.',
      );
    }

    return result;
  }

  int _parseScore(dynamic value) {
    final parsed = value is num
        ? value.round()
        : int.tryParse(value?.toString() ?? '') ?? 0;

    return parsed.clamp(0, 100);
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  String _normalizeSymbol(String value) {
    var result = value.trim().toUpperCase();

    if (result.endsWith('.IS')) {
      result = result.substring(0, result.length - 3);
    }

    return result;
  }

  void clearCache() {
    _cache.clear();
  }
}
