import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/bist/database/bist100_master_database.dart';
import '../../../core/bist/services/bist_universe_service.dart';
import '../../../core/data_foundation/market/yahoo_bist_market_data_source.dart';
import '../../stock_detail/screens/stock_detail_screen.dart';
import 'stock_logo.dart';

class StockCommandPanel extends StatefulWidget {
  const StockCommandPanel({super.key});

  @override
  State<StockCommandPanel> createState() => _StockCommandPanelState();
}

class _StockCommandPanelState extends State<StockCommandPanel> {
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;
  int _searchRequestId = 0;

  final YahooBistMarketDataSource _marketDataSource =
      YahooBistMarketDataSource();

  final BistUniverseService _universeService = BistUniverseService();

  bool _remoteLoading = false;
  String? _remoteError;
  _StockSearchItem? _remoteStock;

  String query = '';

  List<_StockSearchItem> stocks = const [];

  @override
  void initState() {
    super.initState();

    // Gateway geçici olarak ulaşılamazsa ekran boş kalmasın.
    stocks = _buildFallbackStocks();

    _loadBistUniverse();
  }

  List<_StockSearchItem> _buildFallbackStocks() {
    return Bist100MasterDatabase.stocks
        .map(
          (stock) => _StockSearchItem(
            code: stock.code,
            company: stock.name,
            price: 0,
            change: 0,
            aiScore: 0,
            signal: 'DETAYI AÇ',
            institution: stock.sector,
            catalogOnly: true,
          ),
        )
        .toList(growable: false);
  }

  Future<void> _loadBistUniverse() async {
    try {
      final members = await _universeService.fetchActiveCandidates();

      if (!mounted) return;

      if (members.isEmpty) {
        setState(() {});
        return;
      }

      // Önce BIST100 fallback kataloğunu ekliyoruz.
      // Ardından KAP evreni aynı kodları güncelliyor ve
      // BIST100 dışındaki şirketleri de ekliyor.
      final merged = <String, _StockSearchItem>{
        for (final stock in Bist100MasterDatabase.stocks)
          stock.code: _StockSearchItem(
            code: stock.code,
            company: stock.name,
            price: 0,
            change: 0,
            aiScore: 0,
            signal: 'DETAYI AÇ',
            institution: stock.sector,
            catalogOnly: true,
          ),
      };

      for (final member in members) {
        final fallback = Bist100MasterDatabase.findByCode(member.stockCode);

        merged[member.stockCode] = _StockSearchItem(
          code: member.stockCode,
          company: member.title.trim().isNotEmpty
              ? member.title.trim()
              : fallback?.name ?? ' • Borsa İstanbul',
          price: 0,
          change: 0,
          aiScore: 0,
          signal: 'DETAYI AÇ',
          institution: fallback?.sector ?? 'BIST • KAP',
          catalogOnly: true,
        );
      }

      final allStocks = merged.values.toList()
        ..sort((a, b) => a.code.compareTo(b.code));

      setState(() {
        stocks = List<_StockSearchItem>.unmodifiable(allStocks);
      });
    } catch (_) {
      // CROC Data Gateway ulaşılamazsa BIST100 fallback korunur.
      if (!mounted) return;

      setState(() {});
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  List<_StockSearchItem> get filteredStocks {
    final text = _normalize(query);

    if (text.isEmpty) {
      return stocks;
    }

    final local = stocks.where((stock) {
      return _normalize(stock.code).contains(text) ||
          _normalize(stock.company).contains(text) ||
          _normalize(stock.institution).contains(text);
    }).toList();

    final remote = _remoteStock;

    if (remote != null && !local.any((item) => item.code == remote.code)) {
      local.insert(0, remote);
    }

    return local;
  }

  String _normalize(String value) {
    return value
        .trim()
        .toUpperCase()
        .replaceAll('İ', 'I')
        .replaceAll('Ş', 'S')
        .replaceAll('Ğ', 'G')
        .replaceAll('Ü', 'U')
        .replaceAll('Ö', 'O')
        .replaceAll('Ç', 'C');
  }

  void _scheduleRemoteSearch(String value) {
    _searchDebounce?.cancel();

    final code = value.trim().toUpperCase().replaceAll('.IS', '');

    if (!RegExp(r'^[A-Z0-9]{3,8}$').hasMatch(code)) {
      return;
    }

    final hasLocalMatch = stocks.any((stock) => stock.code == code);

    if (hasLocalMatch) {
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 650), () {
      if (!mounted) return;

      final current = query.trim().toUpperCase().replaceAll('.IS', '');

      if (current != code) return;

      searchAllBist(unfocus: false);
    });
  }

  Future<void> searchAllBist({bool unfocus = true}) async {
    final code = query.trim().toUpperCase().replaceAll('.IS', '');
    final requestId = ++_searchRequestId;

    if (code.isEmpty) return;

    if (!RegExp(r'^[A-Z0-9]{2,8}$').hasMatch(code)) {
      setState(() {
        _remoteError =
            'Geçerli bir BIST hisse kodu yaz. Örn: GEREL, BETAE, ASELS';
        _remoteStock = null;
      });
      return;
    }

    if (unfocus) {
      FocusScope.of(context).unfocus();
    }

    setState(() {
      _remoteLoading = true;
      _remoteError = null;
      _remoteStock = null;
    });

    try {
      final snapshot = await _marketDataSource.fetch(
        code,
        range: '1mo',
        interval: '1d',
      );

      if (!mounted) return;

      final currentCode = query.trim().toUpperCase().replaceAll('.IS', '');

      // Kullanıcı bu istek sırasında başka sembol yazdıysa
      // eski cevap ekrana dokunamaz.
      if (requestId != _searchRequestId || currentCode != code) {
        return;
      }

      final localMatch = stocks
          .where((stock) => stock.code == code)
          .cast<_StockSearchItem?>()
          .firstOrNull;

      final stock = _StockSearchItem(
        code: code,
        company: localMatch?.company ?? '$code • Borsa İstanbul',
        price: snapshot.tick.price,
        change: snapshot.tick.changePercent,
        aiScore: 0,
        signal: 'DETAYI AÇ',
        institution: localMatch?.institution ?? 'CROC canlı veri',
        catalogOnly: false,
      );

      setState(() {
        _remoteStock = stock;
        _remoteLoading = false;
        _remoteError = null;
      });
    } catch (error) {
      debugPrint('CROC SEARCH ERROR [$code] => $error');
      debugPrint('CROC SEARCH ERROR TYPE => ${error.runtimeType}');

      if (!mounted) return;

      final currentCode = query.trim().toUpperCase().replaceAll('.IS', '');

      if (requestId != _searchRequestId || currentCode != code) {
        return;
      }

      final integrityError = error is CrocDataIntegrityException;

      setState(() {
        _remoteLoading = false;
        _remoteStock = null;
        _remoteError = integrityError
            ? '$code bulundu ancak veri bütünlüğü doğrulanamadı. CROC analizi durdurdu.'
            : '$code bulunamadı veya canlı veri alınamadı.';
      });
    }
  }

  Future<void> openStock(_StockSearchItem stock) async {
    if (stock.catalogOnly) {
      setState(() {
        _remoteLoading = true;
        _remoteError = null;
      });

      try {
        final snapshot = await _marketDataSource.fetch(
          stock.code,
          range: '1mo',
          interval: '1d',
        );

        if (!mounted) return;

        setState(() {
          _remoteLoading = false;
        });

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StockDetailScreen(
              code: stock.code,
              company: stock.company,
              price: snapshot.tick.price,
              change: snapshot.tick.changePercent,
              aiScore: 0,
            ),
          ),
        );

        return;
      } catch (error) {
        if (!mounted) return;

        final integrityError = error is CrocDataIntegrityException;

        setState(() {
          _remoteLoading = false;
          _remoteError = integrityError
              ? ' bulundu ancak veri bütünlüğü doğrulanamadı. CROC analizi durdurdu.'
              : ' canlı verisi şu an alınamadı.';
        });

        return;
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StockDetailScreen(
          code: stock.code,
          company: stock.company,
          price: stock.price,
          change: stock.change,
          aiScore: stock.aiScore,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = filteredStocks;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF07120F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF193E32)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E88B).withValues(alpha: 0.04),
            blurRadius: 25,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildSearchBox(),
          const SizedBox(height: 15),
          _buildQuickCodes(),
          const SizedBox(height: 15),
          Expanded(
            child: _remoteLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF70F4AD)),
                  )
                : _remoteError != null
                ? _RemoteSearchMessage(
                    message: _remoteError!,
                    onRetry: searchAllBist,
                  )
                : results.isEmpty
                ? _EmptySearchResult(
                    query: query,
                    onSearchAllBist: searchAllBist,
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 9),
                    itemBuilder: (context, index) {
                      final stock = results[index];

                      return _StockResultCard(
                        stock: stock,
                        onTap: () => openStock(stock),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF103B2B),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF38A96F)),
          ),
          child: const Icon(
            Icons.manage_search_rounded,
            color: Color(0xFF70F4AD),
            size: 27,
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hisse Komuta Merkezi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'BIST kataloğunda ara; kod yazarak tüm BIST içinde canlı kontrol et.',
                style: TextStyle(color: Color(0xFF91A69D), fontSize: 11),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF082016),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xFF226747)),
          ),
          child: const Row(
            children: [
              Icon(Icons.circle, color: Color(0xFF70F4AD), size: 8),
              SizedBox(width: 6),
              Text(
                'BIST • CANLI ARAMA',
                style: TextStyle(
                  color: Color(0xFF70F4AD),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return TextField(
      controller: searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => searchAllBist(),
      onChanged: (value) {
        setState(() {
          query = value.toUpperCase();
          _remoteError = null;

          if (_remoteStock?.code != query.trim().replaceAll('.IS', '')) {
            _remoteStock = null;
          }
        });

        _scheduleRemoteSearch(value);
      },
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: 'Kod / şirket / sektör ara... ASELS, THYAO, GEREL, BETAE',
        hintStyle: const TextStyle(color: Color(0xFF6E8179), fontSize: 12),
        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF70F4AD)),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (query.isNotEmpty)
              IconButton(
                tooltip: 'Temizle',
                onPressed: () {
                  searchController.clear();

                  setState(() {
                    query = '';
                    _remoteStock = null;
                    _remoteError = null;
                  });
                },
                icon: const Icon(Icons.close_rounded, color: Color(0xFF91A69D)),
              ),
            IconButton(
              tooltip: 'Tüm BIST içinde ara',
              onPressed: _remoteLoading ? null : searchAllBist,
              icon: const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF70F4AD),
              ),
            ),
          ],
        ),
        filled: true,
        fillColor: const Color(0xFF04100D),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF1A4B38)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF70F4AD), width: 1.4),
        ),
      ),
    );
  }

  Widget _buildQuickCodes() {
    const codes = ['ASELS', 'THYAO', 'AKBNK', 'KCHOL', 'GARAN', 'SAHOL'];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: codes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final code = codes[index];
          final selected = query.toUpperCase() == code;

          return InkWell(
            onTap: () {
              searchController.text = code;

              searchController.selection = TextSelection.collapsed(
                offset: code.length,
              );

              setState(() {
                query = code;
                _remoteError = null;
                _remoteStock = null;
              });

              searchAllBist();
            },
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF103D2B)
                    : const Color(0xFF081712),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF70F4AD)
                      : const Color(0xFF1B4636),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                code,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF70F4AD)
                      : const Color(0xFFA0B2AA),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StockResultCard extends StatelessWidget {
  final _StockSearchItem stock;
  final VoidCallback onTap;

  const _StockResultCard({required this.stock, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final positive = stock.change >= 0;

    final changeColor = positive
        ? const Color(0xFF70F4AD)
        : const Color(0xFFFF6673);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFF081712),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF193F31)),
          ),
          child: Row(
            children: [
              StockLogo(code: stock.code),

              const SizedBox(width: 12),

              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.code,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stock.company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8FA39A),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(flex: 2, child: _MiniSparkline(positive: positive)),

              const SizedBox(width: 14),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    stock.catalogOnly
                        ? 'CANLI AÇ'
                        : '${stock.price.toStringAsFixed(2)} ₺',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    stock.catalogOnly
                        ? 'Gateway'
                        : '${positive ? '+' : ''}${stock.change.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: stock.catalogOnly
                          ? const Color(0xFF91A69D)
                          : changeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 17),

              Column(
                children: [
                  Text(
                    stock.catalogOnly
                        ? '—'
                        : stock.aiScore == 0
                        ? '—'
                        : '${stock.aiScore}',
                    style: const TextStyle(
                      color: Color(0xFF70F4AD),
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'AI SKOR',
                    style: TextStyle(
                      color: Color(0xFF74877F),
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 17),

              SizedBox(
                width: 88,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      stock.signal,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: stock.signal == 'İZLE'
                            ? const Color(0xFFFFC857)
                            : const Color(0xFF70F4AD),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      stock.institution,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color(0xFF91A69D),
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(Icons.chevron_right_rounded, color: Color(0xFF70F4AD)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniSparkline extends StatelessWidget {
  final bool positive;

  const _MiniSparkline({required this.positive});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: CustomPaint(
        painter: _MiniSparklinePainter(positive: positive),
        size: Size.infinite,
      ),
    );
  }
}

class _MiniSparklinePainter extends CustomPainter {
  final bool positive;

  const _MiniSparklinePainter({required this.positive});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final random = math.Random(positive ? 17 : 29);

    final points = <Offset>[];

    var current = positive ? size.height * 0.68 : size.height * 0.30;

    const count = 28;

    for (var i = 0; i < count; i++) {
      final progress = i / (count - 1);

      final trend = positive ? -progress * 14 : progress * 14;

      final noise = (random.nextDouble() - 0.5) * 7;

      current = (size.height * 0.52 + trend + noise).clamp(
        3.0,
        size.height - 3,
      );

      points.add(Offset(progress * size.width, current));
    }

    final path = Path();

    for (var i = 0; i < points.length; i++) {
      final point = points[i];

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    final color = positive ? const Color(0xFF70F4AD) : const Color(0xFFFF6673);

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..strokeCap = StrokeCap.round,
    );

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.14),
            color.withValues(alpha: 0.00),
          ],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _MiniSparklinePainter oldDelegate) {
    return oldDelegate.positive != positive;
  }
}

class _RemoteSearchMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _RemoteSearchMessage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF081712),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF513A2D)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFFFFC857),
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFD5DED9),
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF103D2B),
                foregroundColor: const Color(0xFF70F4AD),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  final String query;
  final VoidCallback onSearchAllBist;

  const _EmptySearchResult({
    required this.query,
    required this.onSearchAllBist,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF081712),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1F4C3A)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.travel_explore_rounded,
              color: Color(0xFF70F4AD),
              size: 34,
            ),
            const SizedBox(height: 12),
            Text(
              query.isEmpty
                  ? 'Hisse kodu veya şirket adı ara.'
                  : '"$query" BIST şirket evreninde bulunamadı.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Kod doğruysa tüm BIST içinde canlı sorgulayabiliriz.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF91A69D), fontSize: 10),
            ),
            const SizedBox(height: 15),
            FilledButton.icon(
              onPressed: onSearchAllBist,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF103D2B),
                foregroundColor: const Color(0xFF70F4AD),
              ),
              icon: const Icon(Icons.radar_rounded, size: 17),
              label: const Text('Tüm BIST İçinde Ara'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockSearchItem {
  final String code;
  final String company;
  final double price;
  final double change;
  final int aiScore;
  final String signal;
  final String institution;
  final bool catalogOnly;

  const _StockSearchItem({
    required this.code,
    required this.company,
    required this.price,
    required this.change,
    required this.aiScore,
    required this.signal,
    required this.institution,
    this.catalogOnly = false,
  });
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;

    if (!iterator.moveNext()) {
      return null;
    }

    return iterator.current;
  }
}
