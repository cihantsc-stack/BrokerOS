import 'package:flutter/material.dart';

import '../../shared/glossary/interactive_glossary_text.dart';

class FundsScreen extends StatefulWidget {
  const FundsScreen({super.key});

  @override
  State<FundsScreen> createState() => _FundsScreenState();
}

class _FundsScreenState extends State<FundsScreen> {
  int selected = 0;

  static const tabs = ['Para Akışı', 'Performans', 'Fon Detay'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020605),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fon Radarı',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const InteractiveGlossaryText(
              'TEFAS fonlarını, para girişlerini ve performansı tek merkezde izle.',
              style: TextStyle(
                color: Color(0xFF91A69D),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                tabs.length,
                (index) => ChoiceChip(
                  label: Text(tabs[index]),
                  selected: selected == index,
                  onSelected: (_) => setState(() => selected = index),
                  selectedColor: const Color(0xFF12482F),
                  backgroundColor: const Color(0xFF07130F),
                  side: BorderSide(
                    color: selected == index
                        ? const Color(0xFF4BE89A)
                        : const Color(0xFF1C4938),
                  ),
                  labelStyle: TextStyle(
                    color: selected == index
                        ? const Color(0xFF70F4AD)
                        : const Color(0xFF9BAEA7),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: KeyedSubtree(
                key: ValueKey(selected),
                child: switch (selected) {
                  0 => const _FundsPanel(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Fon Para Akışı',
                    text:
                        'Hangi fonun hangi hisselere yöneldiğini gösterecek bölüm hazır. Gerçek TEFAS/portföy dağılım veri hattı bağlandığında burada son 5 gün, 1 ay ve 3 ay hareketleri gösterilecek. Sahte rakam gösterilmiyor.',
                  ),
                  1 => const _FundsPanel(
                    icon: Icons.query_stats_rounded,
                    title: 'Fon Performans Liderleri',
                    text:
                        'Fon getirileri günlük, haftalık ve aylık olarak sıralanacak. Kategoriler: hisse senedi, değişken, altın, para piyasası ve borçlanma araçları.',
                  ),
                  _ => const _FundsPanel(
                    icon: Icons.manage_search_rounded,
                    title: 'Fon Detay',
                    text:
                        'Fon kodu seçildiğinde portföy dağılımı, en büyük pozisyonlar, son değişimler, risk ve CROC AI özeti burada açılacak.',
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FundsPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _FundsPanel({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF07130F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E5C43)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF123A2A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF70F4AD), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF9BAEA7),
                    fontSize: 13,
                    height: 1.5,
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
