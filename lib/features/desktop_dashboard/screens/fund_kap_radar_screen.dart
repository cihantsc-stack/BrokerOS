import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FundKapRadarScreen extends StatefulWidget {
  const FundKapRadarScreen({super.key});

  @override
  State<FundKapRadarScreen> createState() => _FundKapRadarScreenState();
}

class _FundKapRadarScreenState extends State<FundKapRadarScreen> {
  static const String _base = 'https://croc-data-gateway.crocai.workers.dev/';

  bool _loading = true;
  bool _loadingDetail = false;
  String? _error;
  List<Map<String, dynamic>> _feed = const [];
  Map<String, dynamic>? _selected;
  Map<String, dynamic>? _detail;

  @override
  void initState() {
    super.initState();
    _load();
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

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final status = await _getJson(Uri.parse('$_base?mode=kap&action=status'));
      final lastIndex =
          int.tryParse(status['lastDisclosureIndex']?.toString() ?? '') ?? 0;
      if (lastIndex <= 0)
        throw Exception('Son KAP bildirim numarası alınamadı.');

      final from = max(1, lastIndex - 2999);
      final feedResult = await _getJson(
        Uri.parse('$_base?mode=kap&action=feed&from=$from'),
      );
      final rawItems = feedResult['items'] is List
          ? feedResult['items'] as List
          : const <dynamic>[];

      final items =
          rawItems
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .where(
                (item) => item['fundCode'] != null || item['fundId'] != null,
              )
              .toList()
            ..sort((a, b) => _indexOf(b).compareTo(_indexOf(a)));

      final visible = items.take(30).toList(growable: false);
      if (!mounted) return;
      setState(() {
        _feed = visible;
        _loading = false;
      });

      if (visible.isNotEmpty) {
        await _select(visible.first);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  int _indexOf(Map<String, dynamic> item) =>
      int.tryParse(item['disclosureIndex']?.toString() ?? '') ?? 0;

  String _text(dynamic value, [String fallback = '']) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  Future<void> _select(Map<String, dynamic> item) async {
    final index = _text(item['disclosureIndex']);
    if (index.isEmpty) return;

    setState(() {
      _selected = item;
      _loadingDetail = true;
      _detail = null;
      _error = null;
    });

    try {
      final reports = item['subReportIds'] is List
          ? item['subReportIds'] as List
          : const <dynamic>[];
      final subReport = reports.isNotEmpty ? reports.first.toString() : '';
      final params = <String, String>{
        'mode': 'kap',
        'action': 'detail',
        'index': index,
        'fileType': 'html',
      };
      if (subReport.isNotEmpty) params['subReport'] = subReport;

      final detail = await _getJson(
        Uri.parse(_base).replace(queryParameters: params),
      );
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _loadingDetail = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingDetail = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF70F4AD)),
      );
    }

    return Container(
      color: const Color(0xFF020605),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FON KAP RADAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Gerçek fon KAP bildirimleri • CROC fon karar motorunun veri katmanı',
                      style: TextStyle(color: Color(0xFF83988F), fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _loading ? null : _load,
                tooltip: 'Yenile',
                icon: const Icon(Icons.refresh_rounded),
                color: const Color(0xFF70F4AD),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Color(0xFFFF6B78), fontSize: 11),
            ),
          ],
          const SizedBox(height: 14),
          Expanded(
            child: _feed.isEmpty
                ? const Center(
                    child: Text(
                      'Son tarama penceresinde fon KAP bildirimi bulunamadı.',
                      style: TextStyle(color: Color(0xFF83988F)),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final mobileLike = constraints.maxWidth < 760;
                      if (mobileLike) {
                        return ListView(
                          children: [
                            ..._feed.map(_feedCard),
                            const SizedBox(height: 12),
                            SizedBox(height: 460, child: _detailPanel()),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 355,
                            child: ListView(
                              children: _feed.map(_feedCard).toList(),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: _detailPanel()),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _feedCard(Map<String, dynamic> item) {
    final index = _text(item['disclosureIndex']);
    final selected = _text(_selected?['disclosureIndex']) == index;
    final fundCode = _text(item['fundCode'], 'FON');
    final title = _text(item['title'], 'Fon KAP bildirimi');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _select(item),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF0C2419) : const Color(0xFF07130F),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF70F4AD)
                  : const Color(0xFF1B4937),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF123A2A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      fundCode,
                      style: const TextStyle(
                        color: Color(0xFF70F4AD),
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '#$index',
                    style: const TextStyle(
                      color: Color(0xFF62766E),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailPanel() {
    if (_loadingDetail) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF70F4AD)),
      );
    }
    if (_detail == null) {
      return const Center(
        child: Text(
          'Bir fon KAP bildirimi seç.',
          style: TextStyle(color: Color(0xFF83988F)),
        ),
      );
    }

    final detail = _detail!;
    final impact = detail['impact'] is Map
        ? Map<String, dynamic>.from(detail['impact'] as Map)
        : <String, dynamic>{};
    final score = int.tryParse(impact['score']?.toString() ?? '') ?? 0;
    final sentiment = _text(impact['sentiment'], 'NÖTR');
    final importance = _text(impact['importance'], 'BİLİNMİYOR');
    final summary = _text(detail['summary'], 'Özet bulunamadı.');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF05100C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF163C2D)),
      ),
      child: ListView(
        children: [
          const Text(
            'CROC ETKİ ÖZETİ',
            style: TextStyle(
              color: Color(0xFF70F4AD),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _badge('SKOR $score'),
              _badge(sentiment),
              _badge(importance),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            summary,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bu veri CROC Fon Intelligence motoruna yalnız gerçek KAP verisi mevcutsa dahil edilir. Veri yoksa olumlu varsayım yapılmaz.',
            style: TextStyle(
              color: Color(0xFFFFC66D),
              fontSize: 10.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2C20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF1F6B4B)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF70F4AD),
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
