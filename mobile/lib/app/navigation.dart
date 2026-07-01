import 'package:flutter/material.dart';

import '../features/ai/ai_screen.dart';
import '../features/decision_center/decision_center_screen.dart';
import '../features/markets/markets_screen.dart';
import '../features/portfolio/portfolio_screen.dart';
import '../features/profile/profile_screen.dart';
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
    MarketsScreen(),
    PortfolioScreen(),
    AiScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Karar'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart_rounded), label: 'Piyasalar'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Portföy'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_rounded), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }
}