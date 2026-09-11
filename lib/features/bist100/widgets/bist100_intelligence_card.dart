import 'package:flutter/material.dart';

import '../../../core/bist/services/bist100_live_intelligence_service.dart';
import '../../../core/bist/services/broker_market_summary_builder.dart';

class Bist100IntelligenceCard extends StatefulWidget {
  final Bist100LiveIntelligenceService service;

  const Bist100IntelligenceCard({super.key, required this.service});

  @override
  State<Bist100IntelligenceCard> createState() =>
      _Bist100IntelligenceCardState();
}

class _Bist100IntelligenceCardState extends State<Bist100IntelligenceCard> {
  late Future<Bist100LiveIntelligenceResult> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.service.load();
  }

  void _refresh() {
    setState(() {
      _future = widget.service.load(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Bist100LiveIntelligenceResult>(
      future: _future,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<Bist100LiveIntelligenceResult> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingCard();
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _ErrorCard(onRetry: _refresh);
            }

            final Bist100LiveIntelligenceResult result = snapshot.data!;
            final summary = const BrokerMarketSummaryBuilder().build(result);
            final breadth = result.intelligence.breadth;
            final sectors = result.intelligence.sectors.take(5).toList();
            final strongest = result.intelligence.strongestStocks
                .take(5)
                .toList();

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF263244)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          'BIST 100 INTELLIGENCE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '100 / 100 hisse tarandı',
                    style: TextStyle(
                      color: result.marketData.isFallback
                          ? Colors.orangeAccent
                          : Colors.greenAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    summary.decision,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    summary.headline,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _Metric(
                          label: 'Broker Score',
                          value: '${summary.score}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Metric(
                          label: 'Güven',
                          value: '%${summary.confidence}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Metric(
                          label: 'Yükselen',
                          value: '${breadth.rising}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Metric(
                          label: 'Düşen',
                          value: '${breadth.falling}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    summary.explanation,
                    style: const TextStyle(
                      color: Color(0xFFD1D5DB),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'EN GÜÇLÜ SEKTÖRLER',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...sectors.map(
                    (sector) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              sector.sector,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Text(
                            '%${sector.averageChange.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: sector.averageChange >= 0
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 35,
                            child: Text(
                              '${sector.score}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'BUGÜNÜN EN GÜÇLÜ 5 HİSSESİ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...strongest.map(
                    (tick) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 70,
                            child: Text(
                              tick.stock.code,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              tick.stock.sector,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white60),
                            ),
                          ),
                          Text(
                            '${tick.changePercent >= 0 ? '+' : ''}'
                            '%${tick.changePercent.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: tick.changePercent >= 0
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.marketData.source,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            );
          },
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 260,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorCard({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        onPressed: onRetry,
        child: const Text('BIST 100 verisini yeniden yükle'),
      ),
    );
  }
}
