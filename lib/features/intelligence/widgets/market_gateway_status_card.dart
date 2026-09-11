import 'package:flutter/material.dart';

import '../../../core/gateway/data_source_status.dart';
import '../../../core/gateway/market_gateway_manager.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class MarketGatewayStatusCard extends StatefulWidget {
  const MarketGatewayStatusCard({super.key});

  @override
  State<MarketGatewayStatusCard> createState() =>
      _MarketGatewayStatusCardState();
}

class _MarketGatewayStatusCardState extends State<MarketGatewayStatusCard> {
  late Future<List<DataSourceStatus>> _future;

  @override
  void initState() {
    super.initState();
    _future = MarketGatewayManager.instance.checkSources();
  }

  void _refresh() {
    setState(() {
      _future = MarketGatewayManager.instance.checkSources();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DataSourceStatus>>(
      future: _future,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<List<DataSourceStatus>> snapshot,
          ) {
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
                        size: 29,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Piyasa Veri Merkezi',
                          style: TextStyle(
                            color: BrokerColors.textMain,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Kaynakları kontrol et',
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'CROC AI kararlarını besleyen veri kaynaklarının bağlantı durumunu gösterir.',
                    style: TextStyle(color: BrokerColors.textSoft, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  if (snapshot.connectionState != ConnectionState.done)
                    const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (!snapshot.hasData)
                    const Text(
                      'Veri kaynakları kontrol edilemedi.',
                      style: TextStyle(color: BrokerColors.textSoft),
                    )
                  else
                    for (final DataSourceStatus source in snapshot.data!) ...[
                      _SourceRow(source: source),
                      const SizedBox(height: 9),
                    ],
                ],
              ),
            );
          },
    );
  }
}

class _SourceRow extends StatelessWidget {
  final DataSourceStatus source;

  const _SourceRow({required this.source});

  @override
  Widget build(BuildContext context) {
    final Color tone = _toneFor(source.state);
    final String detail = source.delay == null
        ? source.state.label
        : '${source.state.label} • ${source.delay!.inMinutes} dk';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source.name,
                  style: const TextStyle(
                    color: BrokerColors.textMain,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  source.description,
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            detail,
            style: TextStyle(
              color: tone,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Color _toneFor(DataSourceState state) {
    switch (state) {
      case DataSourceState.connected:
        return BrokerColors.primary;
      case DataSourceState.delayed:
        return Colors.orange;
      case DataSourceState.planned:
        return Colors.blueGrey;
      case DataSourceState.unavailable:
        return BrokerColors.red;
    }
  }
}
