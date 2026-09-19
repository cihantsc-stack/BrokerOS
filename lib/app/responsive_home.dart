import 'package:flutter/material.dart';

import '../features/desktop_dashboard/screens/desktop_dashboard_screen.dart';
import '../features/mobile_dashboard/screens/mobile_dashboard_screen.dart';

class ResponsiveHome extends StatelessWidget {
  const ResponsiveHome({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 850) {
          return const MobileDashboardScreen();
        }

        return const DesktopDashboardScreen();
      },
    );
  }
}
