import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class KapRadarScreen extends StatefulWidget {
  const KapRadarScreen({super.key});

  @override
  State<KapRadarScreen> createState() => _KapRadarScreenState();
}

class _KapRadarScreenState extends State<KapRadarScreen> {
  static const String _base = 'https://croc-data-gateway.crocai.workers.dev/';

  bool _loadingFeed = true;
  bool _loadingDetail = false;

  String? _error;

  List<Map<String, dynamic>> _feed = [];

  Map<String, dynamic>? _selectedFeedItem;
  Map<String, dynamic>? _selectedDetail;
  Map<String, dynamic>? _selectedProfile;

  final Map<String, Map<String, dynamic>> _detailCache = {};
  final Map<String, Map<String, dynamic>> _profileCache = {};

  @override
  void initState() {
    super.initState();
    _loadRadar();
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await http.get(uri).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Beklenmeyen veri formatı');
    }

    if (decoded['ok'] != true) {
      throw Exception(
        decoded['error']?.toString() ?? 'CROC Data Gateway hata verdi',
      );
    }

    return decoded;
  }

  Future<void> _loadRadar() async {
    if (!mounted) return;

    setState(() {
      _loadingFeed = true;
      _error = null;
    });

    try {
      // ---------------------------------------------------------
      // 1. SON KAP INDEX
      // ---------------------------------------------------------

      final status = await _getJson(
        Uri.parse('${_base}?mode=kap&action=status'),
      );

      final lastIndex =
          int.tryParse(status['lastDisclosureIndex']?.toString() ?? '') ?? 0;

      if (lastIndex <= 0) {
        throw Exception('Son KAP bildirim numarası alınamadı');
      }

      // Son 50 kayıt.
      final from = max(1, lastIndex - 49);

      // ---------------------------------------------------------
      // 2. FEED
      // ---------------------------------------------------------

      final feedResult = await _getJson(
        Uri.parse('${_base}?mode=kap&action=feed&from=$from'),
      );

      final rawItems = feedResult['items'] is List
          ? feedResult['items'] as List
          : <dynamic>[];

      final items = rawItems
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .where(_isRealStockDisclosure)
          .toList();

      items.sort((a, b) => _indexOf(b).compareTo(_indexOf(a)));

      final visible = items.take(15).toList();

      if (!mounted) return;

      setState(() {
        _feed = visible;
        _loadingFeed = false;
      });

      // İlk gerçek bildirimi otomatik aç.
      if (visible.isNotEmpty) {
        await _selectDisclosure(visible.first);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingFeed = false;
        _error = e.toString();
      });
    }
  }

  bool _isRealStockDisclosure(Map<String, dynamic> item) {
    final disclosureClass = _text(item['disclosureClass']).toUpperCase();

    final companyId = _text(item['companyId']);

    if (disclosureClass != 'ODA') {
      return false;
    }

    if (companyId.isEmpty || companyId == '51') {
      return false;
    }

    if (item['fundId'] != null || item['fundCode'] != null) {
      return false;
    }

    final reports = item['subReportIds'] is List
        ? item['subReportIds'] as List
        : <dynamic>[];

    final isTest = reports.any(
      (e) => e.toString().toLowerCase().contains('testnotification'),
    );

    return !isTest;
  }

  int _indexOf(Map<String, dynamic> item) {
    return int.tryParse(item['disclosureIndex']?.toString() ?? '') ?? 0;
  }

  Future<void> _selectDisclosure(Map<String, dynamic> item) async {
    final disclosureIndex = _text(item['disclosureIndex']);

    final companyId = _text(item['companyId']);

    if (disclosureIndex.isEmpty) {
      return;
    }

    setState(() {
      _selectedFeedItem = item;
      _loadingDetail = true;
      _selectedDetail = null;
      _selectedProfile = null;
    });

    try {
      // ---------------------------------------------------------
      // DETAIL CACHE
      // ---------------------------------------------------------

      Map<String, dynamic>? detail = _detailCache[disclosureIndex];

      if (detail == null) {
        final reports = item['subReportIds'] is List
            ? item['subReportIds'] as List
            : <dynamic>[];

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

        detail = await _getJson(
          Uri.parse(_base).replace(queryParameters: params),
        );

        _detailCache[disclosureIndex] = detail;
      }

      // ---------------------------------------------------------
      // COMPANY PROFILE CACHE
      // ---------------------------------------------------------

      Map<String, dynamic>? profile;

      if (companyId.isNotEmpty) {
        profile = _profileCache[companyId];

        if (profile == null) {
          final member = await _getJson(
            Uri.parse(_base).replace(
              queryParameters: {
                'mode': 'kap',
                'action': 'member-detail',
                'id': companyId,
              },
            ),
          );

          final rawProfile = member['profile'];

          if (rawProfile is Map) {
            profile = Map<String, dynamic>.from(rawProfile);

            _profileCache[companyId] = profile;
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _selectedDetail = detail;
        _selectedProfile = profile;
        _loadingDetail = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingDetail = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF020605),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          _header(),
          const SizedBox(height: 16),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF082016),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF176747)),
          ),
          child: const Icon(
            Icons.radar_rounded,
            color: Color(0xFF70F4AD),
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CROC KAP RADAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Son KAP akışını tara • bildirimi seç • CROC etkisini anında gör.',
                style: TextStyle(color: Color(0xFF83988F), fontSize: 12),
              ),
            ],
          ),
        ),

        _statusBadge('MKK / KAP DEV', const Color(0xFF70F4AD)),

        const SizedBox(width: 10),

        IconButton(
          tooltip: 'Radarı yenile',
          onPressed: _loadingFeed ? null : _loadRadar,
          icon: const Icon(Icons.refresh_rounded),
          color: const Color(0xFF70F4AD),
        ),
      ],
    );
  }

  Widget _body() {
    if (_loadingFeed) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF70F4AD)),
      );
    }

    if (_feed.isEmpty) {
      return _emptyState();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: 365, child: _feedPanel()),
        const SizedBox(width: 14),
        Expanded(child: _detailPanel()),
      ],
    );
  }

  Widget _feedPanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF05100C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF163C2D)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  size: 18,
                  color: Color(0xFF70F4AD),
                ),
                const SizedBox(width: 8),
                const Text(
                  'SON KAP AKIŞI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_feed.length} bildirim',
                  style: const TextStyle(
                    color: Color(0xFF71857D),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFF143027)),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: _feed.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _feed[index];

                return _feedCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedCard(Map<String, dynamic> item) {
    final index = _text(item['disclosureIndex']);

    final selected = _text(_selectedFeedItem?['disclosureIndex']) == index;

    final title = _text(item['title'], 'KAP Bildirimi');

    final event = _feedEventLabel(item);

    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: () => _selectDisclosure(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0C2419) : const Color(0xFF08150F),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? const Color(0xFF38B879) : const Color(0xFF173529),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 19,
                  color: selected
                      ? const Color(0xFF70F4AD)
                      : const Color(0xFF53675F),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                _miniBadge(event),
                const Spacer(),
                Text(
                  '#$index',
                  style: const TextStyle(color: Color(0xFF62766E), fontSize: 9),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailPanel() {
    if (_loadingDetail) {
      return Container(
        decoration: _panelDecoration(),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF70F4AD)),
        ),
      );
    }

    if (_selectedDetail == null) {
      return Container(
        decoration: _panelDecoration(),
        child: const Center(
          child: Text(
            'Bir KAP bildirimi seç.',
            style: TextStyle(color: Color(0xFF83988F)),
          ),
        ),
      );
    }

    final data = _selectedDetail!;

    final impact = data['impact'] is Map
        ? Map<String, dynamic>.from(data['impact'])
        : <String, dynamic>{};

    final moneyImpact = impact['moneyImpact'] is Map
        ? Map<String, dynamic>.from(impact['moneyImpact'])
        : <String, dynamic>{};

    final score = _intValue(impact['score']);

    final sentiment = _text(impact['sentiment'], 'NÖTR');

    final importance = _text(impact['importance'], '-');

    final eventTypes = impact['eventTypes'] is List
        ? (impact['eventTypes'] as List).map((e) => e.toString()).toList()
        : <String>[];

    final reasons = impact['reasons'] is List
        ? (impact['reasons'] as List).map((e) => e.toString()).toList()
        : <String>[];

    return Container(
      decoration: _panelDecoration(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _companyHeader(data, sentiment, importance),

            const SizedBox(height: 22),

            if (eventTypes.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: eventTypes.map(_eventBadge).toList(),
              ),

            const SizedBox(height: 20),

            Text(
              _text(data['subject'], 'KAP Bildirimi'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 9),

            Text(
              _text(data['summary'], '-'),
              style: const TextStyle(
                color: Color(0xFFADBEB7),
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 27),

            _scoreBlock(score),

            if (reasons.isNotEmpty) ...[
              const SizedBox(height: 25),
              _sectionTitle('CROC OKUMASI'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: reasons.map(_reasonChip).toList(),
              ),
            ],

            if (moneyImpact['detected'] == true) ...[
              const SizedBox(height: 25),
              _moneyBlock(moneyImpact),
            ],

            if (_selectedProfile != null) ...[
              const SizedBox(height: 25),
              _profileBlock(_selectedProfile!),
            ],

            const SizedBox(height: 20),

            _crocComment(data, score, sentiment, moneyImpact),
          ],
        ),
      ),
    );
  }

  Widget _companyHeader(
    Map<String, dynamic> data,
    String sentiment,
    String importance,
  ) {
    final symbol = _text(data['symbol'], '-');

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF70F4AD),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  symbol,
                  style: const TextStyle(
                    color: Color(0xFF03110A),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _text(data['senderTitle'], '-'),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      _text(data['time'], '-'),
                      style: const TextStyle(
                        color: Color(0xFF7E9189),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statusBadge(sentiment, _sentimentColor(sentiment)),

              _statusBadge('ÖNEM: $importance', const Color(0xFF6C8077)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scoreBlock(int score) {
    return Column(
      children: [
        Row(
          children: [
            _sectionTitle('CROC ETKİ SKORU'),
            const Spacer(),
            Text(
              '$score / 100',
              style: TextStyle(
                color: _scoreColor(score),
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: score.clamp(0, 100) / 100,
            minHeight: 11,
            backgroundColor: const Color(0xFF12241C),
            valueColor: AlwaysStoppedAnimation<Color>(_scoreColor(score)),
          ),
        ),
      ],
    );
  }

  Widget _moneyBlock(Map<String, dynamic> moneyImpact) {
    final strongest = moneyImpact['strongestTryAmount'] is Map
        ? Map<String, dynamic>.from(moneyImpact['strongestTryAmount'])
        : <String, dynamic>{};

    final value = _numberValue(strongest['value']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('PARASAL ETKİ'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _infoCard('TUTAR', _money(value)),
            _infoCard('SEVİYE', _text(moneyImpact['level'], '-')),
            _infoCard('SKOR KATKISI', '+${_intValue(moneyImpact['bonus'])}'),
          ],
        ),
      ],
    );
  }

  Widget _profileBlock(Map<String, dynamic> profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('ŞİRKET BAĞLAMI'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _infoCard('SEKTÖR', _text(profile['sector'], '-'), width: 270),
            _infoCard('PAZAR', _text(profile['market'], '-')),
            _infoCard(
              'SERMAYE',
              _money(_numberValue(profile['paidInCapital'])),
            ),
            _infoCard(
              'ANA ORTAK',
              _text(profile['mainShareholder'], '-'),
              width: 250,
            ),
            _infoCard(
              'ORTAK PAYI',
              profile['mainShareholderRatio'] == null
                  ? '-'
                  : '%${_numberValue(profile['mainShareholderRatio'])?.toStringAsFixed(2)}',
            ),
            _infoCard('ENDEKS', _indexText(profile)),
          ],
        ),
      ],
    );
  }

  Widget _crocComment(
    Map<String, dynamic> data,
    int score,
    String sentiment,
    Map<String, dynamic> moneyImpact,
  ) {
    final subject = _text(data['subject'], 'KAP Bildirimi');

    final eventTypes =
        data['impact'] is Map && (data['impact'] as Map)['eventTypes'] is List
        ? ((data['impact'] as Map)['eventTypes'] as List)
              .map((e) => e.toString())
              .toList()
        : <String>[];

    final moneyDetected = moneyImpact['detected'] == true;

    final moneyLevel = _text(moneyImpact['level'], 'YOK');

    String decision;
    String explanation;
    String warning;

    if (score >= 75) {
      decision = 'GÜÇLÜ POZİTİF KATALİZÖR';
      explanation =
          'Bildirim güçlü etki grubunda. Olay tipi ve mevcut CROC skoru, kısa vadede yatırımcı ilgisini artırabilecek nitelikte.';
      warning =
          'Tek başına AL sinyali değildir; fiyat, hacim, trend ve piyasa koşullarıyla birlikte doğrulanmalıdır.';
    } else if (score >= 60) {
      decision = 'POZİTİF KATALİZÖR';
      explanation =
          'Bildirim olumlu. Şirket açısından destekleyici bir gelişme ve kısa vadeli fiyatlamada pozitif katkı oluşturabilir.';
      warning =
          'Etkinin kalıcılığı şirket ölçeği, sözleşme büyüklüğü ve piyasanın haberi ne ölçüde fiyatladığına bağlıdır.';
    } else if (score <= 35) {
      decision = 'NEGATİF RİSK';
      explanation =
          'Bildirim belirgin negatif risk içeriyor. Kısa vadede satış baskısı veya risk algısında artış görülebilir.';
      warning =
          'Tek başına SAT sinyali değildir; yeni açıklamalar ve fiyat davranışı birlikte izlenmelidir.';
    } else {
      decision = 'SINIRLI / NÖTR ETKİ';
      explanation =
          'Bildirim şu aşamada sınırlı fiyatlama etkisine sahip görünüyor. Yeni gelişmeler gelirse CROC skoru değişebilir.';
      warning =
          'Haber tek başına işlem kararı üretmek için yeterli görülmüyor.';
    }

    final eventText = eventTypes.isEmpty ? subject : eventTypes.join(' • ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF092017),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF216044)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFF70F4AD), size: 21),
              SizedBox(width: 9),
              Text(
                'CROC AI YORUMU',
                style: TextStyle(
                  color: Color(0xFF70F4AD),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            decision,
            style: TextStyle(
              color: _sentimentColor(sentiment),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            explanation,
            style: const TextStyle(
              color: Color(0xFFC0CEC8),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _miniBadge('SKOR $score/100'),
              _miniBadge(sentiment),
              _miniBadge(eventText),
              if (moneyDetected) _miniBadge('PARASAL ETKİ: $moneyLevel'),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFF07140F),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1B3A2E)),
            ),
            child: Text(
              '⚠ $warning',
              style: const TextStyle(
                color: Color(0xFF9EB0A8),
                fontSize: 10.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value, {double width = 175}) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF091711),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFF1B3A2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF70837B),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFD2DDD8),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF90A39B),
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.7,
      ),
    );
  }

  Widget _reasonChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1A14),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFF244438)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFC3D0CB),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _eventBadge(String text) {
    return _statusBadge(text, const Color(0xFF38B879));
  }

  Widget _miniBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0A2118),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6FC99C),
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.55)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: const Color(0xFF05100C),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFF163C2D)),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Text(
        _error ?? 'Uygun KAP bildirimi bulunamadı.',
        style: const TextStyle(color: Color(0xFF8DA098)),
      ),
    );
  }

  String _feedEventLabel(Map<String, dynamic> item) {
    final reports = item['subReportIds'] is List
        ? item['subReportIds'] as List
        : <dynamic>[];

    final text = reports.join(' ').toLowerCase();

    if (text.contains('new-business-relation')) {
      return 'YENİ İŞ';
    }

    if (text.contains('material-event')) {
      return 'ÖZEL DURUM';
    }

    if (text.contains('dividend')) {
      return 'TEMETTÜ';
    }

    if (text.contains('capital')) {
      return 'SERMAYE';
    }

    return _text(item['disclosureType'], 'KAP');
  }

  Color _sentimentColor(String sentiment) {
    final value = sentiment.toUpperCase();

    if (value.contains('NEGATİF')) {
      return const Color(0xFFFF7777);
    }

    if (value.contains('POZİTİF')) {
      return const Color(0xFF70F4AD);
    }

    return const Color(0xFFFFC857);
  }

  Color _scoreColor(int score) {
    if (score >= 65) {
      return const Color(0xFF70F4AD);
    }

    if (score <= 35) {
      return const Color(0xFFFF7777);
    }

    return const Color(0xFFFFC857);
  }

  String _indexText(Map<String, dynamic> profile) {
    if (profile['bist30'] == true) {
      return 'BIST 30';
    }

    if (profile['bist50'] == true) {
      return 'BIST 50';
    }

    if (profile['bist100'] == true) {
      return 'BIST 100';
    }

    return 'ANA ENDEKS YOK';
  }

  String _text(dynamic value, [String fallback = '']) {
    final text = value?.toString().trim() ?? '';

    return text.isEmpty ? fallback : text;
  }

  int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.round();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double? _numberValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }

  String _money(double? value) {
    if (value == null) {
      return '-';
    }

    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(2)} Mr TL';
    }

    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)} Mn TL';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)} Bin TL';
    }

    return '${value.toStringAsFixed(0)} TL';
  }
}
