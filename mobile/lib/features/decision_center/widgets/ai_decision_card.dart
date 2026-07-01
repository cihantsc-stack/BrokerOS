import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class AiDecisionCard extends StatelessWidget {
  const AiDecisionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Row(
            children: [
              Icon(
                Icons.psychology_alt_rounded,
                color: BrokerColors.primary,
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                "Broker AI Kararı",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: BrokerColors.primary.withOpacity(.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "BUGÜNÜN KARARI",
                  style: TextStyle(
                    color: BrokerColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  "ALIM YAPILABİLİR",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  "Bankacılık ve savunma sektörüne güçlü para girişi devam ediyor.",
                  style: TextStyle(
                    color: BrokerColors.textSoft,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          const Row(
            children: [

              Expanded(
                child: _InfoBox(
                  title: "Güven",
                  value: "96%",
                  color: BrokerColors.green,
                ),
              ),

              SizedBox(width: 12),

              Expanded(
                child: _InfoBox(
                  title: "Risk",
                  value: "Orta",
                  color: BrokerColors.orange,
                ),
              ),

            ],
          ),

          const SizedBox(height: 18),

          const Divider(),

          const SizedBox(height: 12),

          const Text(
            "Broker AI bu kararı neden verdi?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          const _Reason("Kurumsal para girişi artıyor"),
          _Reason("PUSU Skoru 94/100"),
          _Reason("RSI aşırı satımdan dönüyor"),
          _Reason("MACD AL sinyali üretti"),
          _Reason("Haber akışı pozitif"),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: BrokerColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {},
              icon: const Icon(Icons.auto_graph),
              label: const Text(
                "Detaylı AI Analizi",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _InfoBox({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textSoft,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Reason extends StatelessWidget {
  final String text;

  const _Reason(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: BrokerColors.green,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}