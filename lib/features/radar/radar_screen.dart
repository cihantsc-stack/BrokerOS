import 'package:flutter/material.dart';

import '../desktop_dashboard/models/daily_trade_candidate.dart';
import '../desktop_dashboard/services/daily_trade_scanner_service.dart';
import '../intelligence/broker_intelligence_screen.dart';
import '../../shared/widgets/broker_page.dart';
import 'widgets/radar_header.dart';
import 'widgets/radar_stock_card.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  late Future<List<DailyTradeCandidate>> _future;

  @override
  void initState() {
    super.initState();
    _future = DailyTradeScannerService.instance.scan();
  }

  void _refresh() {
    setState(() {
      _future = DailyTradeScannerService.instance.scan(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BrokerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RadarHeader(),
          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Yenile'),
            ),
          ),

          const SizedBox(height: 8),

          FutureBuilder<List<DailyTradeCandidate>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    'Radar verisi alınamadı: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              }

              final stocks = snapshot.data ?? const <DailyTradeCandidate>[];

              if (stocks.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    'CROC filtresini geçen gerçek aday bulunamadı.',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return Column(
                children: stocks.map((stock) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: RadarStockCard(
                      stock: stock,
                      onOpenReport: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BrokerIntelligenceScreen(symbol: stock.symbol),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
