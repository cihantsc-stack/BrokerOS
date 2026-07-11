import 'package:flutter/material.dart';

class OpportunityScannerCard extends StatelessWidget {
  const OpportunityScannerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff101827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.greenAccent.withOpacity(.22)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          SizedBox(height: 14),
          _OpportunityRow("ASELS", "BUY", "94%"),
          _OpportunityRow("THYAO", "BUY", "89%"),
          _OpportunityRow("GARAN", "WATCH", "72%"),
          _OpportunityRow("EREGL", "WAIT", "41%"),
        ],
      ),
    );
  }
}

class _OpportunityRow extends StatelessWidget {
  final String code;
  final String decision;
  final String confidence;

  const _OpportunityRow(this.code, this.decision, this.confidence);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color(0xff182234),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              code,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
          ),
          Text(
            decision,
            style: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(width: 14),
          Text(
            confidence,
            style: TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}