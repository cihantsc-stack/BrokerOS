import 'package:flutter/material.dart';

import 'fund_kap_radar_screen.dart';
import 'kap_radar_screen.dart';

class KapRadarHubScreen extends StatefulWidget {
  const KapRadarHubScreen({super.key});

  @override
  State<KapRadarHubScreen> createState() => _KapRadarHubScreenState();
}

class _KapRadarHubScreenState extends State<KapRadarHubScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color(0xFF020605),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(
                  value: 0,
                  icon: Icon(Icons.candlestick_chart_rounded),
                  label: Text('HİSSE KAP'),
                ),
                ButtonSegment<int>(
                  value: 1,
                  icon: Icon(Icons.account_balance_wallet_rounded),
                  label: Text('FON KAP'),
                ),
              ],
              selected: {_selectedTab},
              onSelectionChanged: (selection) {
                setState(() => _selectedTab = selection.first);
              },
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.selected)
                      ? const Color(0xFF04140D)
                      : const Color(0xFF9DB0A8);
                }),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  return states.contains(WidgetState.selected)
                      ? const Color(0xFF70F4AD)
                      : const Color(0xFF0A1813);
                }),
              ),
            ),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _selectedTab,
            children: const [
              KapRadarScreen(),
              FundKapRadarScreen(),
            ],
          ),
        ),
      ],
    );
  }
}
