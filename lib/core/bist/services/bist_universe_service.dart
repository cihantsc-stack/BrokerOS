import 'dart:convert';
import 'package:http/http.dart' as http;

class BistUniverseMember {
  final String id;
  final String title;
  final String stockCode;

  const BistUniverseMember({
    required this.id,
    required this.title,
    required this.stockCode,
  });
}

class BistUniverseService {
  BistUniverseService({http.Client? client})
    : _client = client ?? http.Client();

  static const String _host = 'croc-data-gateway.crocai.workers.dev';

  final http.Client _client;
  static List<BistUniverseMember>? _cache;
  static DateTime? _cacheTime;

  Future<List<BistUniverseMember>> fetchActiveCandidates({
    Duration ttl = const Duration(minutes: 30),
  }) async {
    if (_cache != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < ttl) {
      return _cache!;
    }

    final uri = Uri.https(_host, '/', {'mode': 'kap', 'action': 'members'});

    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception(
        'KAP şirket evreni alınamadı. HTTP ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is! Map<String, dynamic> || decoded['ok'] != true) {
      throw Exception(
        decoded is Map
            ? decoded['error']?.toString() ?? 'KAP şirket evreni alınamadı.'
            : 'KAP şirket evreni yanıtı geçersiz.',
      );
    }

    final rawList = _extractList(decoded);
    final result = <BistUniverseMember>[];
    final seen = <String>{};

    for (final raw in rawList) {
      if (raw is! Map) continue;
      final item = Map<String, dynamic>.from(raw);
      final memberType = item['memberType']?.toString().toUpperCase() ?? '';

      if (!memberType.split(',').map((e) => e.trim()).contains('IGS')) {
        continue;
      }

      final title = item['title']?.toString().trim() ?? '';
      final id = item['id']?.toString().trim() ?? '';
      final stockCodeRaw = item['stockCode']?.toString().trim() ?? '';

      if (stockCodeRaw.isEmpty) continue;

      for (final code in stockCodeRaw.split(',')) {
        final clean = code.toUpperCase().replaceAll('.IS', '').trim();

        if (!RegExp(r'^[A-Z0-9]{3,6}$').hasMatch(clean)) {
          continue;
        }

        if (!seen.add(clean)) continue;

        result.add(BistUniverseMember(id: id, title: title, stockCode: clean));
      }
    }

    result.sort((a, b) => a.stockCode.compareTo(b.stockCode));

    _cache = List.unmodifiable(result);
    _cacheTime = DateTime.now();

    return _cache!;
  }

  List<dynamic> _extractList(Map<String, dynamic> decoded) {
    for (final key in const [
      'members',
      'items',
      'data',
      'results',
      'companies',
    ]) {
      final value = decoded[key];
      if (value is List) return value;
    }

    for (final value in decoded.values) {
      if (value is List) return value;
    }

    return const [];
  }
}
