import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/bist/database/bist100_master_database.dart';
import '../../../core/bist/services/bist_universe_service.dart';
import '../../../core/data_foundation/market/yahoo_bist_market_data_source.dart';
import '../../stock_detail/screens/stock_detail_screen.dart';

class DashboardStockSearch extends StatefulWidget {
  const DashboardStockSearch({super.key});

  @override
  State<DashboardStockSearch> createState() => _DashboardStockSearchState();
}

class _DashboardStockSearchState extends State<DashboardStockSearch> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final BistUniverseService _universeService = BistUniverseService();
  final YahooBistMarketDataSource _marketDataSource =
      YahooBistMarketDataSource();

  Timer? _debounce;
  List<_DashboardSymbol> _symbols = const [];
  String _query = '';
  bool _loadingQuote = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _symbols = _fallback();
    _loadUniverse();
  }

  List<_DashboardSymbol> _fallback() {
    return Bist100MasterDatabase.stocks
        .map((s) => _DashboardSymbol(code: s.code, company: s.name))
        .toList(growable: false);
  }

  Future<void> _loadUniverse() async {
    try {
      final members = await _universeService.fetchActiveCandidates();
      if (!mounted || members.isEmpty) return;

      final merged = <String, _DashboardSymbol>{
        for (final s in Bist100MasterDatabase.stocks)
          s.code: _DashboardSymbol(code: s.code, company: s.name),
      };

      for (final member in members) {
        final fallback = Bist100MasterDatabase.findByCode(member.stockCode);
        merged[member.stockCode] = _DashboardSymbol(
          code: member.stockCode,
          company: member.title.trim().isNotEmpty
              ? member.title.trim()
              : fallback?.name ??
                    '${member.stockCode} \u2022 Borsa \u0130stanbul',
        );
      }

      final all = merged.values.toList()
        ..sort((a, b) => a.code.compareTo(b.code));

      setState(() => _symbols = List.unmodifiable(all));
    } catch (_) {
      // BIST100 fallback remains available.
    }
  }

  String _normalize(String value) {
    return value
        .trim()
        .toUpperCase()
        .replaceAll('\u0130', 'I')
        .replaceAll('\u015e', 'S')
        .replaceAll('\u011e', 'G')
        .replaceAll('\u00dc', 'U')
        .replaceAll('\u00d6', 'O')
        .replaceAll('\u00c7', 'C');
  }

  List<_DashboardSymbol> get _matches {
    final q = _normalize(_query);
    if (q.isEmpty) return const [];

    final exact = <_DashboardSymbol>[];
    final prefix = <_DashboardSymbol>[];
    final other = <_DashboardSymbol>[];

    for (final item in _symbols) {
      final code = _normalize(item.code);
      final company = _normalize(item.company);
      if (code == q) {
        exact.add(item);
      } else if (code.startsWith(q)) {
        prefix.add(item);
      } else if (code.contains(q) || company.contains(q)) {
        other.add(item);
      }
    }

    return [...exact, ...prefix, ...other].take(5).toList(growable: false);
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    setState(() {
      _query = value;
      _error = null;
    });

    final code = value.trim().toUpperCase().replaceAll('.IS', '');
    if (RegExp(r'^[A-Z0-9]{3,8}$').hasMatch(code) &&
        !_symbols.any((s) => s.code == code)) {
      _debounce = Timer(
        const Duration(milliseconds: 650),
        () => _openCode(code),
      );
    }
  }

  Future<void> _openSymbol(_DashboardSymbol symbol) async {
    await _openCode(symbol.code, company: symbol.company);
  }

  Future<void> _openCode(String rawCode, {String? company}) async {
    if (_loadingQuote) return;

    final code = rawCode.trim().toUpperCase().replaceAll('.IS', '');
    if (!RegExp(r'^[A-Z0-9]{2,8}$').hasMatch(code)) {
      setState(() => _error = 'Ge\u00e7erli bir BIST hisse kodu yaz.');
      return;
    }

    setState(() {
      _loadingQuote = true;
      _error = null;
    });

    try {
      final snapshot = await _marketDataSource.fetch(
        code,
        range: '1mo',
        interval: '1d',
      );
      if (!mounted) return;

      final local = _symbols.where((s) => s.code == code);
      final resolvedCompany =
          company ??
          (local.isNotEmpty
              ? local.first.company
              : '$code \u2022 Borsa \u0130stanbul');

      setState(() => _loadingQuote = false);
      _focusNode.unfocus();

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StockDetailScreen(
            code: code,
            company: resolvedCompany,
            price: snapshot.tick.price,
            change: snapshot.tick.changePercent,
            aiScore: 0,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingQuote = false;
        final integrityError = error is CrocDataIntegrityException;
        _error = integrityError
            ? '$code bulundu ancak veri bütünlüğü doğrulanamadı. CROC analizi durdurdu.'
            : '$code bulunamadı veya canlı veri alınamadı.';
      });
    }
  }

  void _submit(String value) {
    final code = value.trim().toUpperCase().replaceAll('.IS', '');
    final exact = _symbols.where((s) => s.code == code);
    if (exact.isNotEmpty) {
      _openSymbol(exact.first);
    } else {
      _openCode(code);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matches = _matches;
    final active = _query.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Focus(
          onFocusChange: (_) {
            if (mounted) setState(() {});
          },
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            enableSuggestions: false,
            onChanged: _onChanged,
            onSubmitted: _submit,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              hintText: 'Hisse ara \u2022 ASELS, THYAO, BFREN...',
              hintStyle: const TextStyle(
                color: Color(0xFF71877D),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF70F4AD),
                size: 21,
              ),
              suffixIcon: _loadingQuote
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
                  : _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Temizle',
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _query = '';
                          _error = null;
                        });
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF71877D),
                        size: 18,
                      ),
                    ),
              filled: true,
              fillColor: const Color(0xFF07120F),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 13,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF193E32)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF38A96F),
                  width: 1.2,
                ),
              ),
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              _error!,
              style: const TextStyle(
                color: Color(0xFFFF8A92),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        if (active && matches.isNotEmpty) ...[
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF07120F),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0xFF1F4C3A)),
            ),
            child: Column(
              children: [
                for (var i = 0; i < matches.length; i++) ...[
                  _DashboardSearchResult(
                    item: matches[i],
                    onTap: () => _openSymbol(matches[i]),
                  ),
                  if (i != matches.length - 1)
                    const Divider(height: 1, color: Color(0xFF163428)),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _DashboardSearchResult extends StatelessWidget {
  final _DashboardSymbol item;
  final VoidCallback onTap;

  const _DashboardSearchResult({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 31,
              height: 31,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF0C241B),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                item.code.substring(0, item.code.length.clamp(0, 2)),
                style: const TextStyle(
                  color: Color(0xFF70F4AD),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.code,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.company,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF80948B),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF70F4AD),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardSymbol {
  final String code;
  final String company;

  const _DashboardSymbol({required this.code, required this.company});
}
