import 'dart:async';
import 'package:flutter/material.dart';

class LiveMarketHeader extends StatefulWidget {
  const LiveMarketHeader({super.key});

  @override
  State<LiveMarketHeader> createState() => _LiveMarketHeaderState();
}

class _LiveMarketHeaderState extends State<LiveMarketHeader> {
  late Timer _timer;
  String _time = "";

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _time =
          "${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}:"
          "${now.second.toString().padLeft(2, '0')}";
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget _box({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff182234),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
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
        color: const Color(0xff101827),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.cyanAccent.withOpacity(.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar, color: Colors.cyanAccent),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "CANLI PİYASA ZEKÂSI",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(.13),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Text(
                  "CANLI",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            _time,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              _box(
                title: "BIST100",
                value: "+1.82%",
                icon: Icons.trending_up,
                color: Colors.greenAccent,
              ),
              _box(
                title: "KORKU ENDEKSİ",
                value: "18.2",
                icon: Icons.warning_amber,
                color: Colors.orangeAccent,
              ),
            ],
          ),

          Row(
            children: [
              _box(
                title: "DOLAR / TL",
                value: "41.12",
                icon: Icons.attach_money,
                color: Colors.lightBlueAccent,
              ),
              _box(
                title: "GRAM ALTIN",
                value: "5281",
                icon: Icons.workspace_premium,
                color: Colors.amberAccent,
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(.13),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bolt, color: Colors.greenAccent, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "AI MODU: ATAK",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                "%92",
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            "GENEL PİYASA RİSKİ",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: const LinearProgressIndicator(
              value: .72,
              minHeight: 11,
              backgroundColor: Color(0xff263449),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
            ),
          ),

          const SizedBox(height: 9),

          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              "72 / 100  •  ORTA",
              style: TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
