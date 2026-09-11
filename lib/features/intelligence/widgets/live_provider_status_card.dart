import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/providers/provider_manager.dart';
import '../../../core/providers/provider_event_bridge.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class LiveProviderStatusCard extends StatefulWidget {
  final String symbol;

  const LiveProviderStatusCard({super.key, required this.symbol});

  @override
  State<LiveProviderStatusCard> createState() => _LiveProviderStatusCardState();
}

class _LiveProviderStatusCardState extends State<LiveProviderStatusCard> {
  late Future<ProviderBundle> _future;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _future = _loadAndPublish();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refresh(),
    );
  }

  @override
  void didUpdateWidget(covariant LiveProviderStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.symbol != widget.symbol) {
      _future = _loadAndPublish();
    }
  }

  Future<ProviderBundle> _loadAndPublish() async {
    final bundle = await ProviderManager.instance.load(widget.symbol);

    ProviderEventBridge.publish(symbol: widget.symbol, bundle: bundle);

    return bundle;
  }

  void _refresh() {
    ProviderManager.instance.clearCache();

    if (!mounted) return;

    setState(() {
      _future = _loadAndPublish();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProviderBundle>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const BrokerCard(child: _LoadingState());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return BrokerCard(child: _ErrorState(onRetry: _refresh));
        }

        return BrokerCard(
          glow: true,
          child: _ProviderContent(bundle: snapshot.data!, onRefresh: _refresh),
        );
      },
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: BrokerColors.primary,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Provider katmanından veriler yükleniyor...',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.cloud_off_rounded, color: BrokerColors.red, size: 27),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Provider verileri alınamadı.',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, color: BrokerColors.primary),
        ),
      ],
    );
  }
}

class _ProviderContent extends StatelessWidget {
  final ProviderBundle bundle;
  final VoidCallback onRefresh;

  const _ProviderContent({required this.bundle, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final updatedAt = bundle.market.updatedAt;
    final time =
        '${updatedAt.hour.toString().padLeft(2, '0')}:'
        '${updatedAt.minute.toString().padLeft(2, '0')}:'
        '${updatedAt.second.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.sensors_rounded,
              color: BrokerColors.primary,
              size: 29,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Data Provider',
                    style: TextStyle(
                      color: BrokerColors.textMain,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Market • Teknik • Kurumsal • Haber • Fon',
                    style: TextStyle(
                      color: BrokerColors.textSoft,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Verileri yenile',
              onPressed: onRefresh,
              icon: const Icon(
                Icons.refresh_rounded,
                color: BrokerColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 17),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _ProviderMetric(
              title: bundle.market.symbol,
              value: bundle.market.price.toStringAsFixed(2),
              subtitle:
                  '${bundle.market.changePercent >= 0 ? '+' : ''}'
                  '${bundle.market.changePercent.toStringAsFixed(2)}%',
              color: bundle.market.changePercent >= 0
                  ? BrokerColors.green
                  : BrokerColors.red,
            ),
            _ProviderMetric(
              title: 'TEKNİK',
              value: '${bundle.technical.score}',
              subtitle: 'RSI ${bundle.technical.rsi.toStringAsFixed(0)}',
              color: BrokerColors.primary,
            ),
            _ProviderMetric(
              title: 'KURUMSAL',
              value: '${bundle.institution.score}',
              subtitle:
                  '${(bundle.institution.netFlow / 1000000000).toStringAsFixed(2)} Mr TL',
              color: BrokerColors.green,
            ),
            _ProviderMetric(
              title: 'HABER',
              value: '${bundle.news.score}',
              subtitle: bundle.news.sentiment,
              color: BrokerColors.orange,
            ),
            _ProviderMetric(
              title: 'FON',
              value: '${bundle.fund.score}',
              subtitle:
                  '${(bundle.fund.weeklyFlow / 1000000).toStringAsFixed(0)} Mn TL',
              color: BrokerColors.green,
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: BrokerColors.cardSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BrokerColors.borderSoft),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: BrokerColors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Provider Manager aktif • 30 sn otomatik yenileme • Cache açık',
                  style: TextStyle(
                    color: BrokerColors.textMain,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  color: BrokerColors.textSoft,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProviderMetric extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _ProviderMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 105, maxWidth: 145),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
