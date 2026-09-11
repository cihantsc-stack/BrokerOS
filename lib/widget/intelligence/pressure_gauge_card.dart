import 'package:flutter/material.dart';

class PressureGaugeCard extends StatelessWidget {
  const PressureGaugeCard({super.key});

  Widget _gauge({
    required String title,
    required double value,
    required String percentText,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xff182234),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                percentText,
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 12,
              backgroundColor: const Color(0xff29384f),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String title, String value, Color color) {
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
                fontWeight: FontWeight.w900,
                fontSize: 17,
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
        border: Border.all(color: Colors.cyanAccent.withOpacity(.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.speed, color: Colors.cyanAccent),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "INSTITUTIONAL PRESSURE GAUGE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Kurum alış/satış baskısı ve Smart Money yönü.",
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 18),
          _gauge(
            title: "Buying Pressure",
            value: .84,
            percentText: "84%",
            color: Colors.greenAccent,
            icon: Icons.call_made,
          ),
          _gauge(
            title: "Selling Pressure",
            value: .16,
            percentText: "16%",
            color: Colors.redAccent,
            icon: Icons.call_received,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _miniStat("Net Para Girişi", "+1.24B", Colors.greenAccent),
              _miniStat("Aktif Kurum", "17", Colors.cyanAccent),
              _miniStat("Hacim Gücü", "Yüksek", Colors.amberAccent),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.cyanAccent.withOpacity(.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.cyanAccent.withOpacity(.18)),
            ),
            child: const Text(
              "Smart Money tarafında alıcı baskı belirgin. Satış baskısı düşük kaldığı için AI tarafında pozitif okuma devam ediyor.",
              style: TextStyle(
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
}
