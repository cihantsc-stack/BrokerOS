import 'package:flutter/material.dart';

class AiMissionCard extends StatelessWidget {
  const AiMissionCard({super.key});

  Widget _missionItem(String text, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xff182234),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.22)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
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
              Icon(Icons.psychology_alt, color: Colors.greenAccent),
              SizedBox(width: 8),
              Text(
                "AI MISSION",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Bugün Broker AI hangi piyasa görevini çalıştırıyor?",
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Wrap(
            children: [
              _tag("OFFENSIVE MODE", Colors.greenAccent),
              _tag("TRADE FOCUS", Colors.cyanAccent),
              _tag("SMART MONEY", Colors.amberAccent),
              _tag("YTD", Colors.white54),
            ],
          ),
          const SizedBox(height: 14),
          _missionItem(
            "Bankacılık ve savunma tarafında güçlü para izi takip ediliyor.",
            Icons.account_balance,
            Colors.greenAccent,
          ),
          _missionItem(
            "Küçük hacimli ve sert oynak hisselerde risk azaltılıyor.",
            Icons.warning_amber,
            Colors.orangeAccent,
          ),
          _missionItem(
            "Kurum alışları, teknik momentum ve haber etkisi aynı potada okunuyor.",
            Icons.hub,
            Colors.cyanAccent,
          ),
          _missionItem(
            "Broker Consensus güçlü değilse AL sinyali tek başına üretilmiyor.",
            Icons.verified,
            Colors.lightBlueAccent,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              "Bugünkü görev: Fırsatı kovala ama stop disiplini olmadan işlem açma.",
              style: TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.w900,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
