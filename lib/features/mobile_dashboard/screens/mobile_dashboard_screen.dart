import 'package:flutter/material.dart';

import '../../ai/ai_screen.dart';
import '../../data_terminal/screens/data_terminal_screen.dart';
import '../../portfolio/portfolio_screen.dart';
import '../../profile/profile_screen.dart';
import '../../radar/radar_screen.dart';

class MobileDashboardScreen extends StatefulWidget {
  const MobileDashboardScreen({super.key});

  @override
  State<MobileDashboardScreen> createState() => _MobileDashboardScreenState();
}

class _MobileDashboardScreenState extends State<MobileDashboardScreen> {
  int _selectedIndex = 0;

  static const Color _background = Color(0xFF020605);
  static const Color _panel = Color(0xFF06100D);
  static const Color _green = Color(0xFF70F4AD);
  static const Color _muted = Color(0xFF91A69D);

  static const List<Widget> _pages = <Widget>[
    DataTerminalScreen(),
    RadarScreen(),
    AiScreen(),
    PortfolioScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: _panel,
          border: Border(top: BorderSide(color: Color(0xFF163B2D))),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            height: 66,
            backgroundColor: _panel,
            indicatorColor: Color(0xFF103B2B),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.candlestick_chart_outlined, color: _muted),
                selectedIcon: Icon(Icons.candlestick_chart, color: _green),
                label: 'Hisseler',
              ),
              NavigationDestination(
                icon: Icon(Icons.radar_outlined, color: _muted),
                selectedIcon: Icon(Icons.radar, color: _green),
                label: 'Radar',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined, color: _muted),
                selectedIcon: Icon(Icons.auto_awesome, color: _green),
                label: 'CROC AI',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: _muted,
                ),
                selectedIcon: Icon(Icons.account_balance_wallet, color: _green),
                label: 'Portföy',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, color: _muted),
                selectedIcon: Icon(Icons.person, color: _green),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
