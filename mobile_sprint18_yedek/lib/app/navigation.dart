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
      backgroundColor: BrokerColors.background,
      body: pages[index],
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          decoration: BoxDecoration(
            color: BrokerColors.cardDeep.withOpacity(.98),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: BrokerColors.border.withOpacity(.82)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.52),
                blurRadius: 26,
                offset: const Offset(0, 14),
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
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, height: 1.45),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, height: 1.45),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: _NavIcon(icon: Icons.home_rounded, selected: false),
                activeIcon: _NavIcon(icon: Icons.home_rounded, selected: true),
                label: 'Ana Sayfa',
              ),
              BottomNavigationBarItem(
                icon: _NavIcon(icon: Icons.radar_rounded, selected: false),
                activeIcon: _NavIcon(icon: Icons.radar_rounded, selected: true),
                label: 'Radar',
              ),
              BottomNavigationBarItem(
                icon: _NavIcon(icon: Icons.psychology_alt_rounded, selected: false),
                activeIcon: _NavIcon(icon: Icons.psychology_alt_rounded, selected: true),
                label: 'CROC AI',
              ),
              BottomNavigationBarItem(
                icon: _NavIcon(icon: Icons.account_balance_wallet_rounded, selected: false),
                activeIcon: _NavIcon(icon: Icons.account_balance_wallet_rounded, selected: true),
                label: 'Portföy',
              ),
              BottomNavigationBarItem(
                icon: _NavIcon(icon: Icons.person_rounded, selected: false),
                activeIcon: _NavIcon(icon: Icons.person_rounded, selected: true),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;

  const _NavIcon({
    required this.icon,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    if (!selected) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Icon(icon, size: 22),
      );
    }

    return Container(
      width: 42,
      height: 30,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        gradient: BrokerColors.crocGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: BrokerColors.primary.withOpacity(.26),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.black, size: 20),
    );
  }
}
