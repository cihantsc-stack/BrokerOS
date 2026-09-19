import 'package:flutter/material.dart';

import '../../../core/institutional_flow/models/broker_flow.dart';
import '../../../core/institutional_flow/models/institutional_direction.dart';
import '../../../core/institutional_flow/models/institutional_flow_snapshot.dart';
import '../../../core/institutional_flow/services/institutional_flow_service.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class InstitutionalFlowCenterCard extends StatefulWidget {
  final String symbol;

  const InstitutionalFlowCenterCard({super.key, required this.symbol});

  @override
  State<InstitutionalFlowCenterCard> createState() =>
      _InstitutionalFlowCenterCardState();
}

class _InstitutionalFlowCenterCardState
    extends State<InstitutionalFlowCenterCard> {
  late Future<InstitutionalFlowSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant InstitutionalFlowCenterCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.symbol != widget.symbol) {
      setState(() {
        _future = _load();
      });
    }
  }

  Future<InstitutionalFlowSnapshot> _load() {
    return InstitutionalFlowService.instance.load(widget.symbol);
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
      child: FutureBuilder<InstitutionalFlowSnapshot>(
        future: _future,
        builder:
            (
              BuildContext context,
              AsyncSnapshot<InstitutionalFlowSnapshot> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 310,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Text(
                  'Kurumsal veri motoru yüklenemedi: '
                  '${snapshot.error ?? 'Bilinmeyen hata'}',
                  style: const TextStyle(color: BrokerColors.red),
                );
              }

              final InstitutionalFlowSnapshot data = snapshot.data!;

              final Color tone = !data.hasRealData
                  ? BrokerColors.textSoft
                  : data.positive
                  ? BrokerColors.primary
                  : BrokerColors.red;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_rounded,
                        color: BrokerColors.primary,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'PRO PACK 1C • Kurumsal Para Merkezi',
                          style: TextStyle(
                            color: BrokerColors.textMain,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Kurumsal veriyi yenile',
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Takas, fon hareketi, yabancı oranı, lot kilidi '
                    've kurum yoğunluğu tek skorda birleşiyor.',
                    style: TextStyle(color: BrokerColors.textSoft, height: 1.4),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: tone.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: tone.withValues(alpha: 0.13)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${data.symbol} KURUMSAL KARAR',
                                style: const TextStyle(
                                  color: BrokerColors.textSoft,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                data.hasRealData
                                    ? data.direction.label
                                    : 'VERİ BEKLENİYOR',
                                style: TextStyle(
                                  color: tone,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          data.hasRealData
                              ? '${data.score.toStringAsFixed(0)}/100'
                              : '—',
                          style: const TextStyle(
                            color: BrokerColors.textMain,
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Veri kapsamı %${data.coveragePercent} • '
                    '${data.activeLayers.length}/5 katman aktif',
                    style: const TextStyle(
                      color: BrokerColors.textSoft,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (data.missingLayers.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      'Beklenen katmanlar: ${data.missingLayers.join(' • ')}',
                      style: const TextStyle(
                        color: Color(0xFFFFC66D),
                        fontSize: 10,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 13),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _MetricChip(
                        title: 'Yabancı',
                        value: '%${data.foreignRatio.toStringAsFixed(1)}',
                      ),
                      const _MetricChip(
                        title: 'Fon Akışı',
                        value: 'VERİ BEKLENİYOR',
                      ),
                      _MetricChip(
                        title: 'Lot Kilidi',
                        value: '%${data.lotLockRatio.toStringAsFixed(0)}',
                      ),
                      _MetricChip(
                        title: 'Yoğunluk',
                        value: '%${data.concentrationRatio.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'İlk 5 Kurum',
                    style: TextStyle(
                      color: BrokerColors.textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 9),
                  ...data.topBrokers.map(
                    (BrokerFlow broker) => _BrokerRow(broker: broker),
                  ),
                ],
              );
            },
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String title;
  final String value;

  const _MetricChip({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        '$title  $value',
        style: const TextStyle(
          color: BrokerColors.textMain,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _BrokerRow extends StatelessWidget {
  final BrokerFlow broker;

  const _BrokerRow({required this.broker});

  @override
  Widget build(BuildContext context) {
    final Color tone = broker.buyer ? BrokerColors.primary : BrokerColors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(
            broker.buyer
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: tone,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              broker.brokerName,
              style: const TextStyle(
                color: BrokerColors.textMain,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${broker.netLot >= 0 ? '+' : ''}'
            '${(broker.netLot / 1000000).toStringAsFixed(2)} Mn',
            style: TextStyle(color: tone, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 13),
          SizedBox(
            width: 58,
            child: Text(
              '%${broker.marketShare.toStringAsFixed(1)}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: BrokerColors.textSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
