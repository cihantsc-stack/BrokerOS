import 'package:flutter/material.dart';

class MobileDashboardScreen extends StatefulWidget {
  const MobileDashboardScreen({super.key});

  @override
  State<MobileDashboardScreen> createState() => _MobileDashboardScreenState();
}

class _MobileDashboardScreenState extends State<MobileDashboardScreen> {
  int selectedIndex = 0;

  static const Color background = Color(0xFF020605);
  static const Color panel = Color(0xFF07130F);
  static const Color panelLight = Color(0xFF0B1C16);
  static const Color green = Color(0xFF70F4AD);
  static const Color muted = Color(0xFF91A69D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: const [
            _MobileHomePage(),
            _ComingSoonPage(
              icon: Icons.radar_rounded,
              title: 'Piyasa Radarı',
              subtitle:
                  'Fırsatlar, para akışı ve güçlü hisseler burada gösterilecek.',
            ),
            _ComingSoonPage(
              icon: Icons.auto_awesome_rounded,
              title: 'CROC AI',
              subtitle:
                  'Yapay zekâ piyasa yorumu ve karar motoru burada açılacak.',
            ),
            _ComingSoonPage(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Portföy',
              subtitle:
                  'Portföy performansı, risk ve varlık dağılımı burada gösterilecek.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 78,
        decoration: const BoxDecoration(
          color: Color(0xFF06100D),
          border: Border(top: BorderSide(color: Color(0xFF163B2D))),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              _navItem(
                index: 0,
                icon: Icons.dashboard_rounded,
                label: 'Merkez',
              ),
              _navItem(index: 1, icon: Icons.radar_rounded, label: 'Radar'),
              _navItem(
                index: 2,
                icon: Icons.auto_awesome_rounded,
                label: 'CROC AI',
              ),
              _navItem(
                index: 3,
                icon: Icons.account_balance_wallet_rounded,
                label: 'Portföy',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final selected = selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44,
              height: 32,
              decoration: BoxDecoration(
                color: selected
                    ? green.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: selected ? green : muted),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: selected ? green : muted,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileHomePage extends StatelessWidget {
  const _MobileHomePage();

  static const Color green = Color(0xFF70F4AD);
  static const Color panel = Color(0xFF07130F);
  static const Color panelLight = Color(0xFF0B1C16);
  static const Color muted = Color(0xFF91A69D);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 18),
          _buildMarketDecision(),
          const SizedBox(height: 14),
          _buildMorningComment(),
          const SizedBox(height: 18),
          const Text(
            'Piyasa Panoraması',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          _buildMarketGrid(),
          const SizedBox(height: 18),
          _buildSectionTitle(
            title: 'Bugünün Fırsatları',
            trailing: 'Tümünü Gör',
          ),
          const SizedBox(height: 10),
          const _OpportunityCard(
            code: 'ASELS',
            company: 'Aselsan',
            score: 94,
            change: '+2.18%',
            signal: 'GÜÇLÜ AL',
          ),
          const SizedBox(height: 10),
          const _OpportunityCard(
            code: 'THYAO',
            company: 'Türk Hava Yolları',
            score: 89,
            change: '+1.46%',
            signal: 'AL',
          ),
          const SizedBox(height: 10),
          const _OpportunityCard(
            code: 'AKBNK',
            company: 'Akbank',
            score: 86,
            change: '+0.92%',
            signal: 'İZLE',
          ),
          const SizedBox(height: 18),
          _buildMoneyFlow(),
          const SizedBox(height: 14),
          _buildRiskCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF103B2B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: green.withValues(alpha: 0.7)),
          ),
          child: const Center(
            child: Text('🐊', style: TextStyle(fontSize: 27)),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CROC AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'powered by Broker OS',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFF194B38)),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildMarketDecision() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2D20), Color(0xFF07130F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF247B55)),
        boxShadow: [
          BoxShadow(color: green.withValues(alpha: 0.08), blurRadius: 24),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: green, size: 18),
              SizedBox(width: 7),
              Text(
                'BUGÜNKÜ PİYASA KARARI',
                style: TextStyle(
                  color: green,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'SEÇİCİ ALIM MODU',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Güçlü bilanço ve kurumsal para girişi olan hisselerde fırsatlar öne çıkıyor.',
            style: TextStyle(
              color: Color(0xFFADC0B8),
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(
                child: _DecisionMetric(title: 'Güven', value: '%92'),
              ),
              SizedBox(width: 9),
              Expanded(
                child: _DecisionMetric(title: 'Risk', value: 'Orta'),
              ),
              SizedBox(width: 9),
              Expanded(
                child: _DecisionMetric(title: 'Mod', value: 'Atak'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMorningComment() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF173E30)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.psychology_alt_rounded, color: green, size: 25),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Sabah Yorumu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Bankacılık ve savunma sektörlerinde pozitif görünüm devam ediyor. Gün içi dalgalanmalarda kademeli hareket et.',
                  style: TextStyle(color: muted, fontSize: 12, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketGrid() {
    return const Row(
      children: [
        Expanded(
          child: _MarketCard(
            title: 'BIST 100',
            value: '11.482',
            change: '+1.82%',
            positive: true,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _MarketCard(
            title: 'DOLAR/TL',
            value: '40.28',
            change: '-0.15%',
            positive: false,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _MarketCard(
            title: 'GRAM ALTIN',
            value: '4.392',
            change: '+0.65%',
            positive: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle({required String title, required String trailing}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            color: green,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildMoneyFlow() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFF1B4D39)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_rounded, color: green, size: 21),
              SizedBox(width: 8),
              Text(
                'Kurumsal Para',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Spacer(),
              Text(
                '+1.24 Milyar TL',
                style: TextStyle(
                  color: green,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          _InstitutionRow(name: 'İş Yatırım', value: '+428 Mn'),
          SizedBox(height: 10),
          _InstitutionRow(name: 'Yapı Kredi Yatırım', value: '+367 Mn'),
          SizedBox(height: 10),
          _InstitutionRow(name: 'Ak Yatırım', value: '+224 Mn'),
        ],
      ),
    );
  }

  Widget _buildRiskCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: panelLight,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFF644E1F)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, color: Color(0xFFFFC857), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Risk Disiplini',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '3 aktif uyarı bulunuyor. Pozisyon boyutunu ve stop seviyelerini kontrol et.',
                  style: TextStyle(color: muted, fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Color(0xFFFFC857)),
        ],
      ),
    );
  }
}

class _DecisionMetric extends StatelessWidget {
  final String title;
  final String value;

  const _DecisionMetric({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF020B08).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFF1D573F)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: Color(0xFF8FA59C), fontSize: 10),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool positive;

  const _MarketCard({
    required this.title,
    required this.value,
    required this.change,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final changeColor = positive
        ? const Color(0xFF70F4AD)
        : const Color(0xFFFF7070);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF07130F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF173E30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF879B92),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            change,
            style: TextStyle(
              color: changeColor,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final String code;
  final String company;
  final int score;
  final String change;
  final String signal;

  const _OpportunityCard({
    required this.code,
    required this.company,
    required this.score,
    required this.change,
    required this.signal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF07130F),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFF173E30)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF103B2B),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: Text(
                code.substring(0, 1),
                style: const TextStyle(
                  color: Color(0xFF70F4AD),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  company,
                  style: const TextStyle(
                    color: Color(0xFF8FA59C),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  color: Color(0xFF70F4AD),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'AI SKOR',
                style: TextStyle(
                  color: Color(0xFF7E9188),
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                change,
                style: const TextStyle(
                  color: Color(0xFF70F4AD),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                signal,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InstitutionRow extends StatelessWidget {
  final String name;
  final String value;

  const _InstitutionRow({required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(color: Color(0xFFA3B6AE), fontSize: 12),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF70F4AD),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ComingSoonPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ComingSoonPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: const Color(0xFF07130F),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF1E5C43)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF103B2B),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF70F4AD)),
                ),
                child: Icon(icon, color: const Color(0xFF70F4AD), size: 34),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF91A69D),
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
