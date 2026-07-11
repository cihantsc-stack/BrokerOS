import 'package:flutter/material.dart';

void main() {
  runApp(const BrokerOSApp());
}

class BrokerOSApp extends StatelessWidget {
  const BrokerOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Broker OS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: BrokerColors.background,
        primaryColor: BrokerColors.primary,
      ),
      home: const MainShell(),
    );
  }
}

class BrokerColors {
  static const background = Color(0xFF090D14);
  static const card = Color(0xFF111827);
  static const cardSoft = Color(0xFF172033);
  static const border = Color(0xFF263244);
  static const primary = Color(0xFF20E3D2);
  static const green = Color(0xFF22C55E);
  static const orange = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
  static const textSoft = Colors.white70;
  static const textMuted = Colors.white38;
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  final pages = const [
    DecisionCenterScreen(),
    MarketsScreen(),
    PortfolioScreen(),
    AiAssistantScreen(),
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

class DecisionCenterScreen extends StatelessWidget {
  const DecisionCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrokerHeader(),
          SizedBox(height: 22),
          MorningBriefCard(),
          SizedBox(height: 16),
          AiScoreCard(),
          SizedBox(height: 16),
          ConsensusCard(),
          SizedBox(height: 16),
          OpportunityCard(),
          SizedBox(height: 16),
          SmartMoneyCard(),
          SizedBox(height: 16),
          NewsImpactCard(),
          SizedBox(height: 16),
          DisclaimerText(),
        ],
      ),
    );
  }
}

class BrokerHeader extends StatelessWidget {
  const BrokerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: BrokerColors.primary, size: 28),
            SizedBox(width: 10),
            Text('Broker OS', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
          ],
        ),
        SizedBox(height: 6),
        Text('Daha bilinçli yatırım kararları için.', style: TextStyle(color: BrokerColors.textSoft)),
      ],
    );
  }
}

class MorningBriefCard extends StatelessWidget {
  const MorningBriefCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrokerBadge(text: 'Sabah Brifingi'),
          SizedBox(height: 14),
          Text('Günaydın Cihan.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(
            'Bugün piyasayı senin için analiz ettim. Genel görünüm pozitif, risk seviyesi orta. Savunma sanayi ve bankacılık tarafında dikkat çekici hareketler var.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class AiScoreCard extends StatelessWidget {
  const AiScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Row(
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const CircularProgressIndicator(
                  value: 0.91,
                  strokeWidth: 10,
                  color: BrokerColors.primary,
                  backgroundColor: BrokerColors.border,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('91', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: BrokerColors.primary)),
                    Text('/100', style: TextStyle(color: BrokerColors.textMuted, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Piyasa Skoru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                SizedBox(height: 8),
                Text('Güçlü pozitif görünüm. Bugün seçici ama fırsat odaklı olmak daha doğru.', style: TextStyle(color: BrokerColors.textSoft, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConsensusCard extends StatelessWidget {
  const ConsensusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Broker Konsensüsü', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ConsensusItem('Olumlu', '17', BrokerColors.green),
              ConsensusItem('Bekle', '12', BrokerColors.orange),
              ConsensusItem('Riskli', '4', BrokerColors.red),
            ],
          ),
        ],
      ),
    );
  }
}

class OpportunityCard extends StatelessWidget {
  const OpportunityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bugünün Fırsatları', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 14),
          AssetRow(code: 'ASELS', title: 'Savunma güçlü', score: 'AI %91'),
          AssetRow(code: 'THYAO', title: 'Hacim artışı', score: 'AI %87'),
          AssetRow(code: 'GARAN', title: 'Para girişi', score: 'AI %84'),
        ],
      ),
    );
  }
}

class SmartMoneyCard extends StatelessWidget {
  const SmartMoneyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Akıllı Para', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('Son 60 dakikada güçlü para girişi izleniyor. Bankacılık ve savunma ön planda.', style: TextStyle(color: BrokerColors.textSoft, height: 1.4)),
        ],
      ),
    );
  }
}

class NewsImpactCard extends StatelessWidget {
  const NewsImpactCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Haber Etkisi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('Günün haber akışı genel olarak pozitif. Öğleden sonra makro veri kaynaklı volatilite artabilir.', style: TextStyle(color: BrokerColors.textSoft, height: 1.4)),
        ],
      ),
    );
  }
}

class MarketsScreen extends StatelessWidget {
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitle('Piyasalar'),
          SizedBox(height: 18),
          BrokerCard(child: Text('Hisse, fon, altın, kripto ve diğer varlık sınıfları burada olacak.', style: TextStyle(color: BrokerColors.textSoft))),
        ],
      ),
    );
  }
}

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitle('Portföy'),
          SizedBox(height: 18),
          BrokerCard(child: Text('Portföy dağılımı, kâr/zarar, risk skoru ve AI yorumları burada olacak.', style: TextStyle(color: BrokerColors.textSoft))),
        ],
      ),
    );
  }
}

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitle('AI Asistan'),
          SizedBox(height: 18),
          BrokerCard(child: Text('Broker OS AI ile konuşma ekranı burada olacak.', style: TextStyle(color: BrokerColors.textSoft))),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitle('Profil'),
          SizedBox(height: 18),
          BrokerCard(child: Text('Dil, tema, risk profili ve abonelik ayarları burada olacak.', style: TextStyle(color: BrokerColors.textSoft))),
        ],
      ),
    );
  }
}

class BrokerPage extends StatelessWidget {
  final Widget child;

  const BrokerPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [child],
      ),
    );
  }
}

class PageTitle extends StatelessWidget {
  final String title;

  const PageTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900));
  }
}

class BrokerCard extends StatelessWidget {
  final Widget child;

  const BrokerCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BrokerColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: BrokerColors.border),
      ),
      child: child,
    );
  }
}

class BrokerBadge extends StatelessWidget {
  final String text;

  const BrokerBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: BrokerColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: BrokerColors.primary.withOpacity(0.4)),
      ),
      child: Text(text, style: const TextStyle(color: BrokerColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

class ConsensusItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const ConsensusItem(this.title, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: BrokerColors.textSoft)),
      ],
    );
  }
}

class AssetRow extends StatelessWidget {
  final String code;
  final String title;
  final String score;

  const AssetRow({super.key, required this.code, required this.title, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrokerColors.border),
      ),
      child: Row(
        children: [
          Text(code, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(color: BrokerColors.textSoft))),
          Text(score, style: const TextStyle(color: BrokerColors.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class DisclaimerText extends StatelessWidget {
  const DisclaimerText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'YTD: Broker OS yatırım tavsiyesi vermez. Veriyi anlamlandırarak karar desteği sağlar.',
      style: TextStyle(color: BrokerColors.textMuted, fontSize: 12),
    );
  }
}
