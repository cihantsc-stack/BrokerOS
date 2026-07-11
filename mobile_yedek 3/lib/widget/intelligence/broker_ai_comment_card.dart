import 'package:flutter/material.dart';

class BrokerAiCommentCard extends StatelessWidget {
  const BrokerAiCommentCard({super.key});

  Widget _point(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: color, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dna(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xff182234),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(.18)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
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
        border: Border.all(color: Colors.purpleAccent.withOpacity(.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.smart_toy, color: Colors.purpleAccent),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "BROKER AI YORUMU",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                "DNA 94",
                style: TextStyle(
                  color: Colors.purpleAccent,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "AI; teknik, kurumsal, haber, momentum ve oyun teorisini birlikte okur.",
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _dna("Teknik", "91", Colors.greenAccent),
              _dna("Kurum", "88", Colors.cyanAccent),
              _dna("Haber", "76", Colors.amberAccent),
            ],
          ),
          Row(
            children: [
              _dna("Momentum", "93", Colors.lightBlueAccent),
              _dna("Risk", "Orta", Colors.orangeAccent),
              _dna("Consensus", "92", Colors.purpleAccent),
            ],
          ),
          const SizedBox(height: 16),
          _point(
            "ASELS tarafında kurumsal para girişi pozitif bölgede kalıyor.",
            Colors.greenAccent,
          ),
          _point(
            "Teknik tarafta momentum güçlü; destek bölgesi üzerinde kalıcılık korunuyor.",
            Colors.cyanAccent,
          ),
          _point(
            "Haber etkisi nötr-pozitif. Savunma sektörü göreceli güçlü kalmaya devam ediyor.",
            Colors.amberAccent,
          ),
          _point(
            "Game Theory okuması: büyük oyuncu fiyatı yukarı taşımadan önce hacim biriktiriyor olabilir.",
            Colors.purpleAccent,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purpleAccent.withOpacity(.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.purpleAccent.withOpacity(.18)),
            ),
            child: const Text(
              "Broker AI sonucu: İşlem fikri pozitif. Ancak stop seviyesi kırılırsa senaryo otomatik olarak bozulur. YTD.",
              style: TextStyle(
                color: Colors.white70,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}