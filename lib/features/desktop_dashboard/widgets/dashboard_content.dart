import 'package:flutter/material.dart';

import 'daily_trade_command_center.dart';
import 'dashboard_stock_search.dart';
import 'hero_world_panel.dart';
import 'market_ticker_strip.dart';
import 'right_intelligence_column.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 850;
        final compactDesktop = constraints.maxWidth < 1180;

        if (mobile) {
          return const SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(10, 8, 10, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionFrame(child: MarketTickerStrip()),
                SizedBox(height: 10),
                DashboardStockSearch(),
                SizedBox(height: 10),
                DailyTradeCommandCenter(),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _DashboardSectionHeader(
                eyebrow: 'CROC AI • MARKET INTELLIGENCE',
                title: 'Piyasanın nabzını tek ekranda gör.',
                subtitle:
                    'Global risk, piyasa modu ve CROC fırsat motoru tek merkezde.',
              ),
              const SizedBox(height: 12),
              if (compactDesktop) ...[
                const SizedBox(height: 470, child: HeroWorldPanel()),
                const SizedBox(height: 12),
                const SizedBox(height: 390, child: RightIntelligenceColumn()),
              ] else
                const SizedBox(
                  height: 500,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 70, child: HeroWorldPanel()),
                      SizedBox(width: 12),
                      Expanded(flex: 30, child: RightIntelligenceColumn()),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              const _SectionFrame(child: MarketTickerStrip()),
              const SizedBox(height: 10),
              const DashboardStockSearch(),
              const SizedBox(height: 14),
              const _DashboardSectionHeader(
                eyebrow: 'CROC FIRSAT MOTORU',
                title: 'Bugün neye bakmalıyız?',
                subtitle:
                    'CROC tarar, adayları süzer. Ayrıntı için hisseye girersin.',
                showLive: false,
              ),
              const SizedBox(height: 10),
              const DailyTradeCommandCenter(),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardSectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final bool showLive;

  const _DashboardSectionHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.showLive = true,
  });

  @override
  Widget build(BuildContext context) {
    final textArea = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: Color(0xFF70F4AD),
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF849A90),
            fontSize: 10,
            height: 1.35,
          ),
        ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: textArea),
        if (showLive) ...[const SizedBox(width: 18), const _LiveBadge()],
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF071712),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFF1B4937)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 6, color: Color(0xFF70F4AD)),
          SizedBox(width: 5),
          Text(
            'CANLI',
            style: TextStyle(
              color: Color(0xFF70F4AD),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionFrame extends StatelessWidget {
  final Widget child;

  const _SectionFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF04100C),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF163D2E)),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(15), child: child),
    );
  }
}
