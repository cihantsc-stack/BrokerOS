import 'package:flutter/material.dart';

import '../../../core/data_foundation/cache/memory_cache.dart';
import '../../../core/data_foundation/data_foundation_service.dart';
import '../../../core/data_foundation/data_foundation_status.dart';
import '../../../core/data_foundation/market/live_data_foundation.dart';
import '../../../core/data_foundation/market/market_tick.dart';
import '../../../core/data_foundation/network/connection_status.dart';
import '../../../core/data_foundation/result/app_result.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class LiveDataFoundationCard extends StatefulWidget {
  final String symbol;

  const LiveDataFoundationCard({super.key, required this.symbol});

  @override
  State<LiveDataFoundationCard> createState() => _LiveDataFoundationCardState();
}

class _LiveDataFoundationCardState extends State<LiveDataFoundationCard> {
  late Future<_FoundationViewData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant LiveDataFoundationCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.symbol != widget.symbol) {
      _future = _load();
    }
  }

  Future<_FoundationViewData> _load({bool forceRefresh = false}) async {
    final DataFoundationStatus status = await DataFoundationService.instance
        .inspect();

    final AppResult<MarketTick> quote = await LiveDataFoundation
        .instance
        .marketRepository
        .getQuote(widget.symbol, forceRefresh: forceRefresh);

    return _FoundationViewData(status: status, quote: quote);
  }

  void _refresh() {
    setState(() {
      _future = _load(forceRefresh: true);
    });
  }

  void _clearCache() {
    MemoryCache.instance.clear();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_FoundationViewData>(
      future: _future,
      builder:
          (BuildContext context, AsyncSnapshot<_FoundationViewData> snapshot) {
            if (!snapshot.hasData) {
              return const BrokerCard(
                child: SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final _FoundationViewData data = snapshot.data!;
            final DataFoundationStatus status = data.status;

            return BrokerCard(
              glow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.hub_rounded,
                        color: BrokerColors.primary,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'PRO PACK 1A • Veri Omurgası',
                          style: TextStyle(
                            color: BrokerColors.textMain,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Önbelleği temizle',
                        onPressed: _clearCache,
                        icon: const Icon(Icons.cleaning_services_rounded),
                      ),
                      IconButton(
                        tooltip: 'Yenile',
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gateway, repository, cache, retry, bağlantı '
                    'kontrolü ve senkronizasyon katmanı aktif.',
                    style: TextStyle(color: BrokerColors.textSoft, height: 1.4),
                  ),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children: [
                      _StatusChip(
                        label: status.connectionStatus.label,
                        positive:
                            status.connectionStatus == ConnectionStatus.online,
                      ),
                      _StatusChip(
                        label: 'Bellek ${status.memoryCacheItems}',
                        positive: true,
                      ),
                      _StatusChip(
                        label: 'Disk ${status.diskCacheItems}',
                        positive: true,
                      ),
                      _StatusChip(
                        label: 'Sync ${status.syncJobCount}',
                        positive: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  data.quote.fold<Widget>(
                    onSuccess: (MarketTick tick) => _QuotePanel(tick: tick),
                    onFailure: (failure) => Text(
                      failure.message,
                      style: const TextStyle(
                        color: BrokerColors.red,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }
}

class _QuotePanel extends StatelessWidget {
  final MarketTick tick;

  const _QuotePanel({required this.tick});

  @override
  Widget build(BuildContext context) {
    final Color tone = tick.isPositive
        ? BrokerColors.primary
        : BrokerColors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: tone.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tick.symbol,
                  style: const TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${tick.source} • önbellek 30 sn',
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            tick.price.toStringAsFixed(2),
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${tick.changePercent >= 0 ? '+' : ''}'
            '${tick.changePercent.toStringAsFixed(2)}%',
            style: TextStyle(color: tone, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool positive;

  const _StatusChip({required this.label, required this.positive});

  @override
  Widget build(BuildContext context) {
    final Color tone = positive ? BrokerColors.primary : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tone,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FoundationViewData {
  final DataFoundationStatus status;
  final AppResult<MarketTick> quote;

  const _FoundationViewData({required this.status, required this.quote});
}
