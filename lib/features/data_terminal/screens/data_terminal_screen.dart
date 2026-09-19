import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../intelligence/broker_intelligence_screen.dart';

import '../../../core/bist/database/bist_index_membership.dart';
import '../../../core/bist/database/bist100_master_database.dart';
import '../models/data_terminal_quote.dart';
import '../services/data_terminal_service.dart';

enum _UniverseFilter { bist100, bist30, gainers, losers }

enum _TerminalSort { codeAsc, codeDesc, changeDesc, volumeDesc, priceDesc }

class DataTerminalScreen extends StatefulWidget {
  const DataTerminalScreen({super.key});

  @override
  State<DataTerminalScreen> createState() => _DataTerminalScreenState();
}

class _DataTerminalScreenState extends State<DataTerminalScreen> {
  static const Map<String, String> _nameOverrides = {
    'PAHOL': 'Pasifik Holding',
    'TAVHL': 'TAV Havalimanları',
    'SISE': 'TÃ¼rkiye ÅiÅŸe ve Cam FabrikalarÄ±',
    'SKBNK': 'Åekerbank',
    'SOKM': 'Åok Marketler',
  };

  final DataTerminalService _service = DataTerminalService();
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;
  int _searchRequestId = 0;

  DataTerminalQuote? _remoteSearchQuote;
  bool _remoteSearchLoading = false;

  List<DataTerminalQuote> _quotes = const [];
  bool _loading = true;
  String? _error;
  _UniverseFilter _filter = _UniverseFilter.bist100;
  _TerminalSort _sort = _TerminalSort.codeAsc;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _load(silent: true),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _repairText(String value) {
    if (!value.contains('Ãƒ') &&
        !value.contains('Ã„') &&
        !value.contains('Ã…') &&
        !value.contains('Ã¢')) {
      return value;
    }

    try {
      return utf8.decode(latin1.encode(value), allowMalformed: true);
    } catch (_) {
      return value;
    }
  }

  String _companyName(String code) {
    final override = _nameOverrides[code];
    if (override != null) return override;

    final stock = Bist100MasterDatabase.findByCode(code);
    if (stock == null) return code;

    return _repairText(stock.name);
  }

  List<MapEntry<String, String>> get _universeEntries {
    return BistIndexMembership.bist100
        .map((code) => MapEntry(code, _companyName(code)))
        .toList(growable: false);
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final quotes = await _service.fetchQuotes(
        _universeEntries,
        concurrency: 12,
      );

      if (!mounted) return;

      setState(() {
        _quotes = quotes;
        _loading = false;
        _error = quotes.isEmpty ? 'Canlı piyasa verisi alınamadı.' : null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _scheduleRemoteSearch(String value) {
    _searchDebounce?.cancel();

    final code = value.trim().toUpperCase().replaceAll('.IS', '');

    // Åirket adÄ± ararken Gateway'e kod diye istek atmayalÄ±m.
    if (!RegExp(r'^[A-Z0-9]{3,8}$').hasMatch(code)) {
      if (_remoteSearchQuote != null || _remoteSearchLoading) {
        setState(() {
          _remoteSearchQuote = null;
          _remoteSearchLoading = false;
        });
      }
      return;
    }

    // Zaten terminalde yüklüyse uzaktan tekrar çekme.
    if (_quotes.any((quote) => quote.code == code)) {
      if (_remoteSearchQuote != null || _remoteSearchLoading) {
        setState(() {
          _remoteSearchQuote = null;
          _remoteSearchLoading = false;
        });
      }
      return;
    }

    final requestId = ++_searchRequestId;

    _searchDebounce = Timer(
      const Duration(milliseconds: 550),
      () => _fetchRemoteSearchQuote(code, requestId),
    );
  }

  Future<void> _fetchRemoteSearchQuote(String code, int requestId) async {
    if (!mounted) return;

    setState(() {
      _remoteSearchLoading = true;
      _remoteSearchQuote = null;
    });

    final quote = await _service.fetchQuote(code);

    if (!mounted) return;

    final currentCode = _searchController.text.trim().toUpperCase().replaceAll(
      '.IS',
      '',
    );

    // Kullanıcı bu sırada başka şey yazdıysa eski cevap çöpe gider.
    if (requestId != _searchRequestId || currentCode != code) {
      return;
    }

    setState(() {
      _remoteSearchLoading = false;
      _remoteSearchQuote = quote;
    });
  }

  List<DataTerminalQuote> get _visibleQuotes {
    final query = _searchController.text.trim().toUpperCase();

    final rows = _quotes.where((quote) {
      if (query.isNotEmpty &&
          !quote.code.contains(query) &&
          !quote.company.toUpperCase().contains(query)) {
        return false;
      }

      switch (_filter) {
        case _UniverseFilter.bist100:
          return true;
        case _UniverseFilter.bist30:
          return BistIndexMembership.isBist30(quote.code);
        case _UniverseFilter.gainers:
          return quote.changePercent > 0;
        case _UniverseFilter.losers:
          return quote.changePercent < 0;
      }
    }).toList();

    // Kullanıcı açıkça bir BIST kodu aradıysa,
    // BIST100 filtresinden bağımsız olarak gerçek Gateway sonucunu göster.
    final remote = _remoteSearchQuote;

    if (query.isNotEmpty &&
        remote != null &&
        !rows.any((quote) => quote.code == remote.code)) {
      rows.insert(0, remote);
    }

    switch (_sort) {
      case _TerminalSort.codeAsc:
        rows.sort((a, b) => a.code.compareTo(b.code));
        break;
      case _TerminalSort.codeDesc:
        rows.sort((a, b) => b.code.compareTo(a.code));
        break;
      case _TerminalSort.changeDesc:
        rows.sort((a, b) => b.changePercent.compareTo(a.changePercent));
        break;
      case _TerminalSort.volumeDesc:
        rows.sort((a, b) => b.volume.compareTo(a.volume));
        break;
      case _TerminalSort.priceDesc:
        rows.sort((a, b) => b.price.compareTo(a.price));
        break;
    }

    return rows;
  }

  String _compact(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(2)}B';
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  String get _filterLabel {
    switch (_filter) {
      case _UniverseFilter.bist100:
        return 'BIST 100';
      case _UniverseFilter.bist30:
        return 'BIST 30';
      case _UniverseFilter.gainers:
        return 'Y\u00DCKSELEN';
      case _UniverseFilter.losers:
        return 'D\u00DC\u015EEN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _visibleQuotes;
    final gainers = _quotes.where((q) => q.changePercent > 0).length;
    final losers = _quotes.where((q) => q.changePercent < 0).length;

    return Scaffold(
      backgroundColor: const Color(0xFF020605),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(gainers: gainers, losers: losers),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF05100D),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF173E30)),
                  ),
                  child: Column(
                    children: [
                      _buildToolbar(),
                      const Divider(height: 1, color: Color(0xFF173E30)),
                      _buildTableHeader(rows.length),
                      const Divider(height: 1, color: Color(0xFF173E30)),
                      Expanded(
                        child: _loading && _quotes.isEmpty
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF70F4AD),
                                ),
                              )
                            : _error != null && _quotes.isEmpty
                            ? _buildError()
                            : ListView.separated(
                                itemCount: rows.length,
                                separatorBuilder: (_, _) => const Divider(
                                  height: 1,
                                  color: Color(0xFF102A21),
                                ),
                                itemBuilder: (context, index) {
                                  final quote = rows[index];
                                  return _QuoteRow(
                                    quote: quote,
                                    volumeText: _compact(quote.volume),
                                    bist30: BistIndexMembership.isBist30(
                                      quote.code,
                                    ),
                                    onTap: () => _openDetail(quote),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({required int gainers, required int losers}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF04100C),
        border: Border(bottom: BorderSide(color: Color(0xFF173E30))),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0D2A1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2B815B)),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              color: Color(0xFF70F4AD),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CROC VER\u0130 TERM\u0130NAL\u0130',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'BIST 100 evreni • 60 sn otomatik yenileme',
                  style: TextStyle(
                    color: Color(0xFF7E968C),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _MiniStat(
            label: 'D\u00DC\u015EEN',
            value: '$gainers',
            color: const Color(0xFF70F4AD),
          ),
          const SizedBox(width: 8),
          _MiniStat(
            label: 'D\u00DC\u015EEN',
            value: '$losers',
            color: const Color(0xFFFF6673),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Canlı veriyi yenile',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF70F4AD)),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 7,
        runSpacing: 8,
        children: [
          SizedBox(
            width: 330,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _remoteSearchQuote = null;
                });

                _scheduleRemoteSearch(value);
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Hisse kodu veya \u015Firket ara...',
                hintStyle: const TextStyle(color: Color(0xFF647A70)),
                prefixIcon: _remoteSearchLoading
                    ? const Padding(
                        padding: EdgeInsets.all(13),
                        child: SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF70F4AD),
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF70F4AD),
                      ),
                filled: true,
                fillColor: const Color(0xFF071712),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1A4937)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1A4937)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF41C982)),
                ),
              ),
            ),
          ),
          _FilterButton(
            title: 'BIST 100',
            selected: _filter == _UniverseFilter.bist100,
            onTap: () => setState(() => _filter = _UniverseFilter.bist100),
          ),
          _FilterButton(
            title: 'BIST 30',
            selected: _filter == _UniverseFilter.bist30,
            onTap: () => setState(() => _filter = _UniverseFilter.bist30),
          ),
          _FilterButton(
            title: 'D\u00DC\u015EEN',
            selected: _filter == _UniverseFilter.gainers,
            onTap: () => setState(() => _filter = _UniverseFilter.gainers),
          ),
          _FilterButton(
            title: 'D\u00DC\u015EEN',
            selected: _filter == _UniverseFilter.losers,
            onTap: () => setState(() => _filter = _UniverseFilter.losers),
          ),
          PopupMenuButton<_TerminalSort>(
            color: const Color(0xFF071712),
            initialValue: _sort,
            tooltip: 'Sıralama',
            onSelected: (value) => setState(() => _sort = value),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _TerminalSort.codeAsc,
                child: Text(
                  'Kod A \u2192 Z',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              PopupMenuItem(
                value: _TerminalSort.codeDesc,
                child: Text(
                  'Kod Z \u2192 A',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              PopupMenuItem(
                value: _TerminalSort.changeDesc,
                child: Text('% değişim', style: TextStyle(color: Colors.white)),
              ),
              PopupMenuItem(
                value: _TerminalSort.volumeDesc,
                child: Text('Hacim', style: TextStyle(color: Colors.white)),
              ),
              PopupMenuItem(
                value: _TerminalSort.priceDesc,
                child: Text('Fiyat', style: TextStyle(color: Colors.white)),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFF071712),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: const Color(0xFF1A4937)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sort_by_alpha_rounded,
                    color: Color(0xFF70F4AD),
                    size: 17,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'SIRALA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(int visibleCount) {
    const style = TextStyle(
      color: Color(0xFF789087),
      fontSize: 9,
      fontWeight: FontWeight.w900,
      letterSpacing: .4,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 620;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: mobile
              ? Row(
                  children: [
                    Expanded(
                      child: Text(
                        'H\u0130SSE ($_filterLabel) ($visibleCount)',
                        style: style,
                      ),
                    ),
                    const SizedBox(
                      width: 76,
                      child: Text(
                        'F\u0130YAT',
                        textAlign: TextAlign.right,
                        style: style,
                      ),
                    ),
                    const SizedBox(
                      width: 82,
                      child: Text(
                        'DE\u011E\u0130\u015E\u0130M',
                        textAlign: TextAlign.right,
                        style: style,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        'H\u0130SSE \u2022 $_filterLabel ($visibleCount)',
                        style: style,
                      ),
                    ),
                    const Expanded(
                      flex: 2,
                      child: Text('\u015E\u0130RKET', style: style),
                    ),
                    const SizedBox(
                      width: 110,
                      child: Text(
                        'F\u0130YAT',
                        textAlign: TextAlign.right,
                        style: style,
                      ),
                    ),
                    const SizedBox(
                      width: 100,
                      child: Text(
                        'DE\u011E\u0130\u015E\u0130M',
                        textAlign: TextAlign.right,
                        style: style,
                      ),
                    ),
                    const SizedBox(
                      width: 110,
                      child: Text(
                        'HAC\u0130M',
                        textAlign: TextAlign.right,
                        style: style,
                      ),
                    ),
                    const SizedBox(width: 42),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFFFF6673),
              size: 34,
            ),
            const SizedBox(height: 10),
            Text(
              _error ?? 'Canl\u0131 veri al\u0131namad\u0131.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF9EB0A8), fontSize: 11),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('TEKRAR DENE')),
          ],
        ),
      ),
    );
  }

  void _openDetail(DataTerminalQuote quote) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BrokerIntelligenceScreen(symbol: quote.code),
      ),
    );
  }
}

class _QuoteRow extends StatelessWidget {
  final DataTerminalQuote quote;
  final String volumeText;
  final bool bist30;
  final VoidCallback onTap;

  const _QuoteRow({
    required this.quote,
    required this.volumeText,
    required this.bist30,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final positive = quote.changePercent >= 0;
    final color = positive ? const Color(0xFF70F4AD) : const Color(0xFFFF6673);

    return InkWell(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < 620;

          if (mobile) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              quote.code,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (bist30) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFFFC857,
                                  ).withValues(alpha: .10),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text(
                                  '30',
                                  style: TextStyle(
                                    color: Color(0xFFFFC857),
                                    fontSize: 7,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          quote.company,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF82978E),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 76,
                    child: Text(
                      quote.price.toStringAsFixed(2),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 82,
                    child: Text(
                      '${positive ? '+' : ''}${quote.changePercent.toStringAsFixed(2)}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Row(
                    children: [
                      Text(
                        quote.code,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (bist30) ...[
                        const SizedBox(width: 6),
                        const Text(
                          '30',
                          style: TextStyle(
                            color: Color(0xFFFFC857),
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    quote.company,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF91A69D),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Text(
                    quote.price.toStringAsFixed(2),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    '${positive ? '+' : ''}${quote.changePercent.toStringAsFixed(2)}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Text(
                    volumeText,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFF82978E),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 42,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF38D98A),
                    size: 20,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7F948A),
              fontSize: 7,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF103B2A) : const Color(0xFF071712),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF3AC47C) : const Color(0xFF1A4937),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? const Color(0xFF70F4AD) : const Color(0xFF8FA39A),
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
