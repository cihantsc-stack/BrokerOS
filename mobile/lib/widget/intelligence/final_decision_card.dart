import 'package:flutter/material.dart';

class FinalDecisionCard extends StatelessWidget {
  const FinalDecisionCard({super.key});

  Widget _stat(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xff182234),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(.20)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.greenAccent.withOpacity(.16),
            const Color(0xff101827),
            Colors.cyanAccent.withOpacity(.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.greenAccent.withOpacity(.30)),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(.08),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "BROKER AI",
            style: TextStyle(
              color: Colors.white60,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "FINAL DECISION",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(.13),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.greenAccent.withOpacity(.30)),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Colors.greenAccent,
                  size: 44,
                ),
                SizedBox(height: 10),
                Text(
                  "GÜÇLÜ AL",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Broker Consensus: Pozitif",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _stat("Confidence", "%92", Colors.cyanAccent),
              _stat("Risk", "Orta", Colors.orangeAccent),
            ],
          ),
          Row(
            children: [
              _stat("Vade", "3-7 Gün", Colors.lightBlueAccent),
              _stat("Beklenen", "+12%", Colors.greenAccent),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xff182234),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              "Karar özeti: Kurumsal para, teknik görünüm ve momentum aynı yönde. Stop disiplini korunursa trade için pozitif senaryo aktif. YTD.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}