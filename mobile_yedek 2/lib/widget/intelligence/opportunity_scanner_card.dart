import 'package:flutter/material.dart';

class OpportunityScannerCard extends StatelessWidget {
  const OpportunityScannerCard({super.key});

  Widget _row(String code, String name, String decision, String confidence, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xff182234), borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withOpacity(.20))),
      child: Row(children: [
        CircleAvatar(backgroundColor: color.withOpacity(.14), child: Icon(icon, color: color, size: 21)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 3),
          Text(name, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(decision, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(height: 4),
          Text(confidence, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
        ]),
      ]),
    );
  }

  Widget _chip(String text, Color color) => Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(color: color.withOpacity(.11), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(.20))),
        child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xff101827), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.greenAccent.withOpacity(.22))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.travel_explore, color: Colors.greenAccent), SizedBox(width: 8), Text('FIRSAT TARAYICI', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))]),
        const SizedBox(height: 6),
        const Text('Broker AI bugün en güçlü fırsatları tarıyor.', style: TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 14),
        Wrap(children: [_chip('BIST30', Colors.cyanAccent), _chip('Akıllı Para', Colors.greenAccent), _chip('Momentum', Colors.amberAccent), _chip('Düşük Risk', Colors.lightBlueAccent)]),
        const SizedBox(height: 12),
        _row('ASELS', 'Savunma / Yüksek Momentum', 'AL', '94%', Colors.greenAccent, Icons.rocket_launch),
        _row('THYAO', 'Ulaştırma / Kurumsal Alım', 'AL', '89%', Colors.greenAccent, Icons.flight_takeoff),
        _row('GARAN', 'Bankacılık / İzleme', 'İZLE', '72%', Colors.amberAccent, Icons.visibility),
        _row('EREGL', 'Demir Çelik / Zayıf Momentum', 'BEKLE', '41%', Colors.orangeAccent, Icons.pause_circle),
      ]),
    );
  }
}
