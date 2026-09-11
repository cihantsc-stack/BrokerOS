import 'package:flutter/material.dart';

import '../../../core/market_adapters/market_adapter_service.dart';
import '../../../core/market_adapters/models/market_asset_type.dart';
import '../../../core/market_adapters/models/normalized_market_quote.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class MarketAdapterCenterCard extends StatefulWidget {
  final String symbol;

  const MarketAdapterCenterCard({super.key, required this.symbol});

  @override
  State<MarketAdapterCenterCard> createState() =>
      _MarketAdapterCenterCardState();
}

class _MarketAdapterCenterCardState extends State<MarketAdapterCenterCard> {
  late Future<List<NormalizedMarketQuote>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant MarketAdapterCenterCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.symbol != widget.symbol) {
      setState(() {
        _future = _load();
      });
    }
  }

  Future<List<NormalizedMarketQuote>> _load() {
    return MarketAdapterService.instance.load(widget.symbol);
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cable_rounded,
                color: BrokerColors.primary,
                size: 30,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'PRO PACK 1B • Market Adapter Center',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Adaptörleri yenile',
                onPressed: _refresh,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Text(
            'BIST, VİOP, döviz, altın, kripto ve TEFAS '
            'verileri tek formata dönüştürülüyor.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.4),
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<NormalizedMarketQuote>>(
            future: _future,
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<List<NormalizedMarketQuote>> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 170,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text(
                      'Adaptör hatası: ${snapshot.error}',
                      style: const TextStyle(color: BrokerColors.red),
                    );
                  }

                  final List<NormalizedMarketQuote> quotes =
                      snapshot.data ?? <NormalizedMarketQuote>[];

                  if (quotes.isEmpty) {
                    return const SizedBox(
                      height: 120,
                      child: Center(
                        child: Text(
                          'Gösterilecek piyasa verisi bulunamadı.',
                          style: TextStyle(color: BrokerColors.textSoft),
                        ),
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final bool compact = constraints.maxWidth < 720;

                          final double itemWidth = compact
                              ? constraints.maxWidth
                              : (constraints.maxWidth - 12) / 2;

                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: quotes.map((NormalizedMarketQuote quote) {
                              return SizedBox(
                                width: itemWidth,
                                child: _AdapterQuoteTile(quote: quote),
                              );
                            }).toList(),
                          );
                        },
                  );
                },
          ),
        ],
      ),
    );
  }
}

class _AdapterQuoteTile extends StatelessWidget {
  final NormalizedMarketQuote quote;

  const _AdapterQuoteTile({required this.quote});

  @override
  Widget build(BuildContext context) {
    final Color tone = quote.isPositive
        ? BrokerColors.primary
        : BrokerColors.red;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: tone.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _assetLabel(quote.assetType),
              style: TextStyle(
                color: tone,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quote.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: BrokerColors.textMain,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  quote.delayed ? '${quote.source} • DEMO' : quote.source,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                quote.price.toStringAsFixed(quote.price < 20 ? 4 : 2),
                style: const TextStyle(
                  color: BrokerColors.textMain,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${quote.changePercent >= 0 ? '+' : ''}'
                '${quote.changePercent.toStringAsFixed(2)}%',
                style: TextStyle(color: tone, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _assetLabel(MarketAssetType type) {
  switch (type) {
    case MarketAssetType.bist:
      return 'BIST';
    case MarketAssetType.viop:
      return 'VİOP';
    case MarketAssetType.forex:
      return 'DÖVİZ';
    case MarketAssetType.gold:
      return 'ALTIN';
    case MarketAssetType.crypto:
      return 'KRİPTO';
    case MarketAssetType.tefas:
      return 'TEFAS';
  }
}
