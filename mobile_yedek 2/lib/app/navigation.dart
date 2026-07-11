import 'package:flutter/material.dart';

import '../features/ai/ai_screen.dart';
import '../features/mission/decision_center_screen.dart';
import '../features/portfolio/portfolio_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/radar/radar_screen.dart';
import '../shared/design/broker_colors.dart';

class BrokerNavigation extends StatefulWidget {
  const BrokerNavigation({super.key});

  @override
  State<BrokerNavigation> createState() => _BrokerNavigationState();
}

class _BrokerNavigationState extends State<BrokerNavigation> {
  int index = 0;

  final pages = const [
    DecisionCenterScreen(),
    RadarScreen(),
    AiScreen(),
    PortfolioScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (value) => setState(() => index = value),
        backgroundColor: BrokerColors.card,
        selectedItemColor: BrokerColors.primary,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_rounded),
            label: 'Mission',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.radar_rounded),
            label: 'Radar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_alt_rounded),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Portföy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}