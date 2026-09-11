import 'package:flutter/material.dart';

class BottomAnalytics extends StatelessWidget {
  const BottomAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _Card('TREND', 'Yükseliş', 'Kısa, orta ve uzun vade pozitif'),
        ),
        SizedBox(width: 9),
        Expanded(child: _Card('DESTEKLER', '154.40', '149.20 • 144.80')),
        SizedBox(width: 9),
        Expanded(child: _Card('DİRENÇLER', '163.80', '168.50 • 171.50')),
        SizedBox(width: 9),
        Expanded(
          child: _Card('HACİM ANALİZİ', 'Artan Hacim', 'Ortalamanın üzerinde'),
        ),
        SizedBox(width: 9),
        Expanded(
          child: _Card(
            'RİSK / GETİRİ',
            '1 : 2.8',
            'Risk orta • Potansiyel yüksek',
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _Card(this.title, this.value, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF07120F),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF193E32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Color(0xFF82968E), fontSize: 9),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF5AF0A2),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFFA4B7B0), fontSize: 8),
          ),
        ],
      ),
    );
  }
}
