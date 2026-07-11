import 'package:flutter/material.dart';

class GlobalRiskCard extends StatelessWidget {
  const GlobalRiskCard({super.key});

  Widget _riskItem({required String title, required String value, required double percent, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff182234),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 9,
              backgroundColor: const Color(0xff29384f),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff101827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orangeAccent.withOpacity(.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.shield_moon, color: Colors.orangeAccent),
            SizedBox(width: 8),
            Text('KÜRESEL RİSK MOTORU', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 6),
          const Text('Broker AI dünya piyasalarını tek ekranda analiz eder.', style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 18),
          _riskItem(title: 'Volatilite Riski', value: 'Orta', percent: .58, color: Colors.orangeAccent),
          _riskItem(title: 'Kur Baskısı', value: 'Yüksek', percent: .74, color: Colors.redAccent),
          _riskItem(title: 'BIST Momentumu', value: 'Pozitif', percent: .82, color: Colors.greenAccent),
          _riskItem(title: 'Yabancı Para Girişi', value: 'Güçlü', percent: .79, color: Colors.cyanAccent),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.orangeAccent.withOpacity(.22)),
            ),
            child: const Text(
              'BROKER AI KARARI\n\nRisk seviyesi şu an ORTA. Kurumsal para girişi devam ediyor. BIST tarafında pozitif görünüm korunuyor. Kur ve küresel piyasalardaki hareketler takip edilmelidir.',
              style: TextStyle(color: Colors.white70, height: 1.35, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
