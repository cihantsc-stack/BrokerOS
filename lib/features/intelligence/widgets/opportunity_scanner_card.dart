import 'package:flutter/material.dart';

class OpportunityScannerCard extends StatelessWidget {
  const OpportunityScannerCard({super.key});

  Widget _opportunity({
    required String code,
    required String name,
    required String decision,
    required String confidence,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xff182234),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(.20)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.14),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  name,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                decision,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                confidence,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.11),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.20)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
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
        border: Border.all(color: Colors.greenAccent.withOpacity(.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.travel_explore, color: Colors.greenAccent),
              SizedBox(width: 8),
              Text(
                "AI OPPORTUNITY SCANNER",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Broker AI bugün en güçlü fırsatları tarıyor.",
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 14),
          Wrap(
            children: [
              _filterChip("BIST30", Colors.cyanAccent),
              _filterChip("Smart Money", Colors.greenAccent),
              _filterChip("Momentum", Colors.amberAccent),
              _filterChip("Low Risk", Colors.lightBlueAccent),
            ],
          ),
          const SizedBox(height: 12),
          _opportunity(
            code: "ASELS",
            name: "Savunma / Yüksek Momentum",
            decision: "BUY",
            confidence: "94%",
            color: Colors.greenAccent,
            icon: Icons.rocket_launch,
          ),
          _opportunity(
            code: "THYAO",
            name: "Ulaştırma / Kurumsal Alım",
            decision: "BUY",
            confidence: "89%",
            color: Colors.greenAccent,
            icon: Icons.flight_takeoff,
          ),
          _opportunity(
            code: "GARAN",
            name: "Bankacılık / İzleme",
            decision: "WATCH",
            confidence: "72%",
            color: Colors.amberAccent,
            icon: Icons.visibility,
          ),
          _opportunity(
            code: "EREGL",
            name: "Demir Çelik / Zayıf Momentum",
            decision: "WAIT",
            confidence: "41%",
            color: Colors.orangeAccent,
            icon: Icons.pause_circle,
          ),
        ],
      ),
    );
  }
}
