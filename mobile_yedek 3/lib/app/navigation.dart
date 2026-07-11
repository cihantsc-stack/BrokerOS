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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: BrokerColors.cardDeep.withOpacity(.96),
          border: const Border(top: BorderSide(color: BrokerColors.borderSoft)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.35),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (value) => setState(() => index = value),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: BrokerColors.primary,
          unselectedItemColor: BrokerColors.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.radar_rounded),
              label: 'Radar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_alt_rounded),
              label: 'CROC AI',
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
      ),
    );
  }
}
