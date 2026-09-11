import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/data_foundation/market/global_market_data_source.dart';
import '../../../shared/glossary/interactive_glossary_text.dart';

class MarketTickerStrip extends StatefulWidget {
  const MarketTickerStrip({super.key});

  @override
  State<MarketTickerStrip> createState() => _MarketTickerStripState();
}

class _MarketTickerStripState extends State<MarketTickerStrip>
    with SingleTickerProviderStateMixin {
  final ScrollController _controller = ScrollController();

  final GlobalMarketDataSource _market = GlobalMarketDataSource();

  Timer? _refreshTimer;
  Timer? _resumeTimer;

  bool _userInteracting = false;

  late final Ticker _motionTicker;
  Duration? _lastMotionElapsed;
  List<_TickerData> _items = const [];

  bool _loading = true;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();

    _loadMarkets();

    _refreshTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => _loadMarkets(),
    );

    _motionTicker = createTicker(_onMotionTick);
    _motionTicker.start();
  }

  Future<GlobalMarketQuote?> _safeFetch(String symbol) async {
    try {
      return await _market.fetch(symbol);
    } catch (error) {
      debugPrint('CROC ticker veri hatası [$symbol]: $error');

      return null;
    }
  }

  Future<void> _loadMarkets() async {
    if (_refreshing) {
      return;
    }

    _refreshing = true;

    try {
      final results = await Future.wait<GlobalMarketQuote?>([
        _safeFetch('XU100.IS'),
        _safeFetch('XU030.IS'),
        _safeFetch('USDTRY=X'),
        _safeFetch('EURTRY=X'),
        _safeFetch('GC=F'),
        _safeFetch('BTC-USD'),
        _safeFetch('BZ=F'),
      ]);

      if (!mounted) {
        return;
      }

      final bist = results[0];
      final bist30 = results[1];
      final usdTry = results[2];
      final eurTry = results[3];
      final gold = results[4];
      final bitcoin = results[5];
      final brent = results[6];

      final newItems = <_TickerData>[];

      if (bist != null) {
        newItems.add(
          _TickerData(
            title: 'BIST 100',
            value: _formatNumber(bist.price, decimals: 2),
            change: bist.changePercent,
            icon: Icons.show_chart_rounded,
          ),
        );
      }

      if (bist30 != null) {
        newItems.add(
          _TickerData(
            title: 'BIST 30',
            value: _formatNumber(bist30.price, decimals: 2),
            change: bist30.changePercent,
            icon: Icons.stacked_line_chart_rounded,
          ),
        );
      }

      if (usdTry != null) {
        newItems.add(
          _TickerData(
            title: 'USD / TRY',
            value: '₺${_formatNumber(usdTry.price, decimals: 4)}',
            change: usdTry.changePercent,
            icon: Icons.attach_money_rounded,
          ),
        );
      }

      if (eurTry != null) {
        newItems.add(
          _TickerData(
            title: 'EUR / TRY',
            value: '₺${_formatNumber(eurTry.price, decimals: 4)}',
            change: eurTry.changePercent,
            icon: Icons.euro_rounded,
          ),
        );
      }

      if (gold != null && usdTry != null) {
        const ounceToGram = 31.1034768;

        final gramGold = (gold.price / ounceToGram) * usdTry.price;

        final previousGramGold =
            (gold.previousClose / ounceToGram) * usdTry.previousClose;

        final gramChange = previousGramGold == 0
            ? 0.0
            : ((gramGold - previousGramGold) / previousGramGold) * 100;

        newItems.add(
          _TickerData(
            title: 'GRAM ALTIN',
            value: '${_formatNumber(gramGold, decimals: 2)} ₺',
            change: gramChange,
            icon: Icons.diamond_outlined,
          ),
        );
      }

      if (gold != null) {
        newItems.add(
          _TickerData(
            title: 'ONS ALTIN',
            value: '\$${_formatNumber(gold.price, decimals: 2)}',
            change: gold.changePercent,
            icon: Icons.workspace_premium_rounded,
          ),
        );
      }

      if (bitcoin != null) {
        newItems.add(
          _TickerData(
            title: 'BITCOIN',
            value: '\$${_formatNumber(bitcoin.price, decimals: 0)}',
            change: bitcoin.changePercent,
            icon: Icons.currency_bitcoin_rounded,
          ),
        );
      }

      if (brent != null) {
        newItems.add(
          _TickerData(
            title: 'BRENT PETROL',
            value: '\$${_formatNumber(brent.price, decimals: 2)}',
            change: brent.changePercent,
            icon: Icons.local_gas_station_rounded,
          ),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;

        if (newItems.isNotEmpty) {
          _items = newItems;
        }
      });
    } catch (error, stackTrace) {
      debugPrint('CROC piyasa bandı genel hatası: $error');

      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });
    } finally {
      _refreshing = false;
    }
  }

  String _formatNumber(double value, {int decimals = 2}) {
    final negative = value < 0;

    final absoluteValue = value.abs();

    final fixed = absoluteValue.toStringAsFixed(decimals);

    final parts = fixed.split('.');

    final integer = parts[0];

    final reversed = integer.split('').reversed.toList();

    final formattedReversed = <String>[];

    for (var i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        formattedReversed.add('.');
      }

      formattedReversed.add(reversed[i]);
    }

    final formattedInteger = formattedReversed.reversed.join();

    final prefix = negative ? '-' : '';

    if (decimals == 0) {
      return '$prefix$formattedInteger';
    }

    return '$prefix$formattedInteger,${parts[1]}';
  }

  void _onMotionTick(Duration elapsed) {
    if (!mounted) return;

    final previous = _lastMotionElapsed;
    _lastMotionElapsed = elapsed;

    if (previous == null ||
        _userInteracting ||
        !_controller.hasClients ||
        _items.isEmpty) {
      return;
    }

    final elapsedMs = (elapsed - previous).inMicroseconds / 1000.0;

    if (elapsedMs <= 0) return;

    final max = _controller.position.maxScrollExtent;
    if (max <= 0) return;

    // Yaklaşık 15 px/sn: yavaş, terminal tipi akış.
    final distance = 15.0 * (elapsedMs / 1000.0);

    final resetPoint = max / 2;
    final next = _controller.offset + distance;

    if (next >= resetPoint) {
      _controller.jumpTo(0);
    } else {
      _controller.jumpTo(next);
    }
  }

  void _pauseAutoTicker() {
    _resumeTimer?.cancel();
    _userInteracting = true;
  }

  void _resumeAutoTicker() {
    _resumeTimer?.cancel();

    _resumeTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      _userInteracting = false;
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _resumeTimer?.cancel();
    _motionTicker.dispose();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 850;

    if (_loading && _items.isEmpty) {
      return Container(
        height: 82,
        decoration: BoxDecoration(
          color: const Color(0xFF07120F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF193E32)),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF70F4AD),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Canlı piyasalar yükleniyor...',
              style: TextStyle(
                color: Color(0xFF81958D),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Container(
        height: 82,
        decoration: BoxDecoration(
          color: const Color(0xFF07120F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF4B252A)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFFFF6371),
              size: 18,
            ),
            const SizedBox(width: 9),
            const Text(
              'Piyasa verisi alınamadı',
              style: TextStyle(
                color: Color(0xFFFF6371),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: _loadMarkets,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Text(
                  'Tekrar dene',
                  style: TextStyle(
                    color: Color(0xFF70F4AD),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final displayItems = [..._items, ..._items];

    return SizedBox(
      height: 82,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: const BoxDecoration(color: Color(0xFF020B08)),
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) => _pauseAutoTicker(),
            onPointerUp: (_) => _resumeAutoTicker(),
            onPointerCancel: (_) => _resumeAutoTicker(),
            child: ListView.separated(
              controller: mobile ? null : _controller,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: displayItems.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = displayItems[index];

                return SizedBox(
                  width: mobile ? 168 : 178,
                  child: _Ticker(
                    title: item.title,
                    value: item.value,
                    change: item.change,
                    icon: item.icon,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TickerData {
  final String title;
  final String value;
  final double change;
  final IconData icon;

  const _TickerData({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
  });
}

class _Ticker extends StatelessWidget {
  final String title;
  final String value;
  final double change;
  final IconData icon;

  const _Ticker({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final negative = change < 0;

    final accent = negative ? const Color(0xFFFF6371) : const Color(0xFF5AF0A2);

    final changeText = '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%';

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF07120F),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF193E32)),
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: const Color(0xFF0C241B),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFF1E543D)),
            ),
            child: Icon(icon, color: const Color(0xFF70F4AD), size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InteractiveGlossaryText(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF81958D),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              changeText,
              style: TextStyle(
                color: accent,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
