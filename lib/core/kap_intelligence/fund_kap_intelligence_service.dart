import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

class FundKapIntelligenceResult {
  final String fundCode;
  final int score;
  final String sentiment;
  final String importance;
  final List<String> eventTypes;
  final List<String> reasons;
  final String summary;
  final String disclosureIndex;
  final String time;
  final String link;

  const FundKapIntelligenceResult({
    required this.fundCode,
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

  static const empty = FundKapIntelligenceResult(
    fundCode: '',
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

class FundKapIntelligenceService {
  FundKapIntelligenceService._();

  static final FundKapIntelligenceService instance =
      FundKapIntelligenceService._();

  static const String _base = 'https://croc-data-gateway.crocai.workers.dev/';

  final Map<String, FundKapIntelligenceResult> _cache = {};
  Future<List<Map<String, dynamic>>>? _feedFuture;
  DateTime? _feedLoadedAt;

  Future<FundKapIntelligenceResult> analyzeFund(String rawFundCode) async {
    final fundCode = _normalizeFundCode(rawFundCode);
    if (fundCode.isEmpty) return FundKapIntelligenceResult.empty;

    final cached = _cache[fundCode];
    if (cached != null) return cached;

    try {
      final feed = await _recentFeed();
      final matches = feed.where((item) {
        final code = _normalizeFundCode(item['fundCode']?.toString() ?? '');
        return code == fundCode;
      }).toList()..sort((a, b) => _indexOf(b).compareTo(_indexOf(a)));

      if (matches.isEmpty) return FundKapIntelligenceResult.empty;

      final item = matches.first;
      final disclosureIndex = item['disclosureIndex']?.toString().trim() ?? '';
      if (disclosureIndex.isEmpty) return FundKapIntelligenceResult.empty;

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
      if (subReport.isNotEmpty) params['subReport'] = subReport;

      final detail = await _getJson(
        Uri.parse(_base).replace(queryParameters: params),
      );

      final impactRaw = detail['impact'];
      final impact = impactRaw is Map
          ? Map<String, dynamic>.from(impactRaw)
          : <String, dynamic>{};

      final result = FundKapIntelligenceResult(
        fundCode: fundCode,
        score: _parseScore(impact['score']),
        sentiment: impact['sentiment']?.toString().trim().isNotEmpty == true
            ? impact['sentiment'].toString().trim()
            : 'NÖTR',
        importance: impact['importance']?.toString().trim().isNotEmpty == true
            ? impact['importance'].toString().trim()
            : 'BİLİNMİYOR',
        eventTypes: _stringList(impact['eventTypes']),
        reasons: _stringList(impact['reasons']),
        summary: detail['summary']?.toString().trim() ?? '',
        disclosureIndex: disclosureIndex,
        time: detail['time']?.toString() ?? '',
        link: detail['link']?.toString() ?? '',
      );

      _cache[fundCode] = result;
      return result;
    } catch (_) {
      return FundKapIntelligenceResult.empty;
    }
  }

  Future<List<Map<String, dynamic>>> _recentFeed() {
    final loadedAt = _feedLoadedAt;
    if (_feedFuture != null &&
        loadedAt != null &&
        DateTime.now().difference(loadedAt) < const Duration(minutes: 3)) {
      return _feedFuture!;
    }

    _feedLoadedAt = DateTime.now();
    _feedFuture = _loadRecentFeed();
    return _feedFuture!;
  }

  Future<List<Map<String, dynamic>>> _loadRecentFeed() async {
    final status = await _getJson(Uri.parse('$_base?mode=kap&action=status'));
    final lastIndex =
        int.tryParse(status['lastDisclosureIndex']?.toString() ?? '') ?? 0;
    if (lastIndex <= 0) return const [];

    final from = max(1, lastIndex - 2999);
    final feed = await _getJson(
      Uri.parse('$_base?mode=kap&action=feed&from=$from'),
    );
    final rawItems = feed['items'] is List ? feed['items'] as List : const [];

    return rawItems
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((item) => item['fundCode'] != null || item['fundId'] != null)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await http
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('KAP Gateway HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map) throw Exception('KAP Gateway geçersiz cevap.');

    final result = Map<String, dynamic>.from(decoded);
    if (result['ok'] == false) {
      throw Exception(result['error']?.toString() ?? 'KAP Gateway hatası.');
    }
    return result;
  }

  int _indexOf(Map<String, dynamic> item) =>
      int.tryParse(item['disclosureIndex']?.toString() ?? '') ?? 0;

  int _parseScore(dynamic value) {
    final parsed = value is num
        ? value.round()
        : int.tryParse(value?.toString() ?? '') ?? 0;
    return parsed.clamp(0, 100);
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  String _normalizeFundCode(String value) {
    final code = value.trim().toUpperCase();
    return RegExp(r'^[A-Z0-9]{2,10}$').hasMatch(code) ? code : '';
  }

  void clearCache() {
    _cache.clear();
    _feedFuture = null;
    _feedLoadedAt = null;
  }
}
