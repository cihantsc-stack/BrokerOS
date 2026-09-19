import 'package:flutter/material.dart';

import '../../ai/ai_screen.dart';
import '../../croc_decision/screens/croc_decision_lab_screen.dart';
import '../../data_terminal/screens/data_terminal_screen.dart';
import '../../funds/funds_screen.dart';
import '../../portfolio/portfolio_screen.dart';
import '../widgets/dashboard_content.dart';
import '../widgets/desktop_sidebar.dart';
import '../widgets/desktop_top_bar.dart';
import 'kap_radar_hub_screen.dart';

class DesktopDashboardScreen extends StatefulWidget {
  const DesktopDashboardScreen({super.key});

  @override
  State<DesktopDashboardScreen> createState() => _DesktopDashboardScreenState();
}

class _DesktopDashboardScreenState extends State<DesktopDashboardScreen> {
  int selectedIndex = 0;

  final GlobalKey<ScaffoldState> _mobileScaffoldKey =
      GlobalKey<ScaffoldState>();

  Widget _pageForIndex(int index, {required bool mobile}) {
    Widget page;

    switch (index) {
      case 0:
        page = const DashboardContent();
        break;
      case 1:
        page = const DataTerminalScreen();
        break;
      case 2:
        page = const AiScreen();
        break;
      case 3:
        page = const CrocDecisionLabScreen();
        break;
      case 4:
        page = const PortfolioScreen();
        break;
      case 5:
        page = const FundsScreen();
        break;
      case 6:
        page = const KapRadarHubScreen();
        break;
      default:
        page = const DashboardContent();
    }

    if (index == 0) return page;

    return mobile
        ? _MobilePageFrame(child: page)
        : _DesktopPageFrame(child: page);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 850;
        return mobile ? _buildMobileShell() : _buildDesktopShell();
      },
    );
  }

  Widget _buildDesktopShell() {
    return Scaffold(
      backgroundColor: const Color(0xFF020605),
      body: Row(
        children: [
          DesktopSidebar(
            selectedIndex: selectedIndex,
            onSelected: (value) {
              setState(() => selectedIndex = value);
            },
          ),
          Expanded(
            child: Column(
              children: [
                const DesktopTopBar(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: KeyedSubtree(
                      key: ValueKey<int>(selectedIndex),
                      child: _pageForIndex(selectedIndex, mobile: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileShell() {
    return Scaffold(
      key: _mobileScaffoldKey,
      backgroundColor: const Color(0xFF020605),
      drawer: Drawer(
        width: 260,
        backgroundColor: const Color(0xFF04100C),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 18, 16, 14),
                child: Row(
                  children: [
                    Text('🐊', style: TextStyle(fontSize: 27)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CROC AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'powered by Broker OS',
                            style: TextStyle(
                              color: Color(0xFF71877D),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFF173E30)),
              const SizedBox(height: 10),
              _MobileDrawerItem(
                icon: Icons.home_rounded,
                title: 'Ana Sayfa',
                selected: selectedIndex == 0,
                onTap: () => _selectMobilePage(0),
              ),
              _MobileDrawerItem(
                icon: Icons.table_chart_rounded,
                title: 'Veri Terminali',
                selected: selectedIndex == 1,
                onTap: () => _selectMobilePage(1),
              ),
              _MobileDrawerItem(
                icon: Icons.psychology_alt_rounded,
                title: 'AI',
                selected: selectedIndex == 2,
                onTap: () => _selectMobilePage(2),
              ),
              _MobileDrawerItem(
                icon: Icons.route_rounded,
                title: 'Karar Merkezi',
                selected: selectedIndex == 3,
                onTap: () => _selectMobilePage(3),
              ),
              _MobileDrawerItem(
                icon: Icons.pie_chart_rounded,
                title: 'Portföy',
                selected: selectedIndex == 4,
                onTap: () => _selectMobilePage(4),
              ),
              _MobileDrawerItem(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Fon Merkezi',
                selected: selectedIndex == 5,
                onTap: () => _selectMobilePage(5),
              ),
              _MobileDrawerItem(
                icon: Icons.notifications_active_rounded,
                title: 'KAP Radar',
                selected: selectedIndex == 6,
                onTap: () => _selectMobilePage(6),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'CROC AI • CANLI',
                  style: TextStyle(
                    color: Color(0xFF70F4AD),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 40 || constraints.maxHeight < 80) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                _MobileTopBar(
                  title: _mobileTitle(selectedIndex),
                  onMenuTap: () {
                    _mobileScaffoldKey.currentState?.openDrawer();
                  },
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: KeyedSubtree(
                      key: ValueKey<int>(selectedIndex),
                      child: _pageForIndex(selectedIndex, mobile: true),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _selectMobilePage(int index) {
    Navigator.pop(context);
    setState(() => selectedIndex = index);
  }

  String _mobileTitle(int index) {
    switch (index) {
      case 0:
        return 'CROC AI';
      case 1:
        return 'Veri Terminali';
      case 2:
        return 'AI';
      case 3:
        return 'Karar Merkezi';
      case 4:
        return 'Portföy';
      case 5:
        return 'Fon Merkezi';
      case 6:
        return 'KAP Radar';
      default:
        return 'CROC AI';
    }
  }
}

class _MobileTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onMenuTap;

  const _MobileTopBar({required this.title, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF04100C),
        border: Border(bottom: BorderSide(color: Color(0xFF173E30))),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Menü',
            onPressed: onMenuTap,
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.menu_rounded,
              color: Color(0xFF70F4AD),
              size: 26,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: -.2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF082117),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF245F43)),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, size: 6, color: Color(0xFF70F4AD)),
                SizedBox(width: 5),
                Text(
                  'CANLI',
                  style: TextStyle(
                    color: Color(0xFF70F4AD),
                    fontSize: 7.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopPageFrame extends StatelessWidget {
  final Widget child;

  const _DesktopPageFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF020605),
      padding: const EdgeInsets.all(14),
      child: ClipRRect(borderRadius: BorderRadius.circular(18), child: child),
    );
  }
}

class _MobilePageFrame extends StatelessWidget {
  final Widget child;

  const _MobilePageFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF020605),
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: child),
    );
  }
}

class _MobileDrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _MobileDrawerItem({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF70F4AD) : const Color(0xFF91A69D);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: selected ? const Color(0xFF0A2118) : Colors.transparent,
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
        trailing: selected
            ? const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF70F4AD),
                size: 18,
              )
            : null,
      ),
    );
  }
}
