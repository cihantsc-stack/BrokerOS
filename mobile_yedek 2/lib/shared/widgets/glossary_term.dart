import 'package:flutter/material.dart';

import '../design/broker_colors.dart';

class GlossaryTerm extends StatelessWidget {
  final String term;
  final String explanation;

  const GlossaryTerm({
    super.key,
    required this.term,
    required this.explanation,
  });

  void _showExplanation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff101827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: BrokerColors.primary.withOpacity(.35)),
          ),
          title: Text(
            term,
            style: const TextStyle(
              color: BrokerColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            explanation,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _showExplanation(context),
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: BrokerColors.primary.withOpacity(.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: BrokerColors.primary.withOpacity(.24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              term,
              style: const TextStyle(
                color: BrokerColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.touch_app_rounded,
              color: BrokerColors.primary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
