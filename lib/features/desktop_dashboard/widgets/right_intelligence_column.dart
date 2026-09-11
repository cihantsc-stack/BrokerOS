import 'package:flutter/material.dart';

import '../../../shared/glossary/interactive_glossary_text.dart';
import '../models/daily_trade_candidate.dart';
import '../services/daily_trade_scanner_service.dart';
import '../services/market_master_decision_service.dart';

class RightIntelligenceColumn extends StatefulWidget {
  const RightIntelligenceColumn({super.key});

  @override
  State<RightIntelligenceColumn> createState() =>
      _RightIntelligenceColumnState();
}

class _RightIntelligenceColumnState extends State<RightIntelligenceColumn> {
  late Future<List<DailyTradeCandidate>> _future;

  final MarketMasterDecisionService _masterService =
      const MarketMasterDecisionService();

  @override
  void initState() {
    super.initState();
    _future = DailyTradeScannerService.instance.scan();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DailyTradeCandidate>>(
      future: _future,
      builder: (context, snapshot) {
        final loading =
            snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData;

        final candidates = snapshot.data ?? const <DailyTradeCandidate>[];

        final scanner = DailyTradeScannerService.instance;
        final master = _masterService.evaluate(
          candidates: candidates,
          sectors: scanner.latestSectorStrengths,
          globalScore: scanner.latestGlobalScore,
        );

        return Column(
          children: [
            Expanded(
              child: _MarketModeCard(loading: loading, master: master),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _AiDecisionCard(loading: loading, master: master),
            ),
            const SizedBox(height: 8),
            const Expanded(child: _InstitutionCard()),
            const SizedBox(height: 8),
            const Expanded(child: _SmartMoneyCard()),
          ],
        );
      },
    );
  }
}

class _MarketModeCard extends StatelessWidget {
  final bool loading;
  final MarketMasterDecision master;

  const _MarketModeCard({required this.loading, required this.master});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'PİYASA MODU',
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    loading ? 'TARANIYOR' : master.mode,
                    style: const TextStyle(
                      color: Color(0xFF63F5A8),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  loading
                      ? 'BIST 100 analiz ediliyor'
                      : '${master.riskLabel} • Sektör ${master.sectorScore} • Global ${master.globalScore}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFA4B7B0), fontSize: 8),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _ScoreRing(loading ? '...' : '${master.score}'),
        ],
      ),
    );
  }
}

class _AiDecisionCard extends StatelessWidget {
  final bool loading;
  final MarketMasterDecision master;

  const _AiDecisionCard({required this.loading, required this.master});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'CROC AI KARARI',
      child: Row(
        children: [
          _ScoreRing(loading ? '...' : master.grade),
          const SizedBox(width: 10),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                loading ? 'ANALİZ\nSÜRÜYOR' : master.aiDecision,
                style: const TextStyle(
                  color: Color(0xFF63F5A8),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  height: 1.18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstitutionCard extends StatelessWidget {
  const _InstitutionCard();

  @override
  Widget build(BuildContext context) {
    return const _Panel(
      title: 'KURUMSAL İŞLEMLER',
      child: _WaitingDataBody(
        icon: Icons.account_balance_rounded,
        headline: 'VERİ BEKLENİYOR',
        text:
            'AKD, kurum bazlı net alım/satım ve takas verisi bağlandığında burada gösterilecek.',
      ),
    );
  }
}

class _SmartMoneyCard extends StatelessWidget {
  const _SmartMoneyCard();

  @override
  Widget build(BuildContext context) {
    return const _Panel(
      title: 'SMART MONEY AKIŞI',
      child: _WaitingDataBody(
        icon: Icons.show_chart_rounded,
        headline: 'VERİ BEKLENİYOR',
        text:
            'Gerçek kurumsal para akışı bağlanmadan CROC burada tutar veya yön uydurmaz.',
      ),
    );
  }
}

class _WaitingDataBody extends StatelessWidget {
  final IconData icon;
  final String headline;
  final String text;

  const _WaitingDataBody({
    required this.icon,
    required this.headline,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFC857), size: 25),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headline,
                style: const TextStyle(
                  color: Color(0xFFFFC857),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF82978E),
                  fontSize: 7.2,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;

  const _Panel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
      decoration: BoxDecoration(
        color: const Color(0xFF07120F),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFF20533F)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00EC88).withValues(alpha: .05),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InteractiveGlossaryText(
            title,
            style: const TextStyle(
              color: Color(0xFFB9CAC3),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: .35,
            ),
          ),
          const SizedBox(height: 3),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  final String value;
  const _ScoreRing(this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF63F5A8), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF63F5A8).withValues(alpha: .18),
            blurRadius: 12,
          ),
        ],
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Color(0xFF63F5A8),
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
