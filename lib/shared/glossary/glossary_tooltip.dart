import 'package:flutter/material.dart';
import '../design/broker_colors.dart';
import 'glossary_data.dart';

class GlossaryTooltip {
  GlossaryTooltip._();

  static void show(BuildContext context, GlossaryItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.72),
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: BrokerColors.darkGradient,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: BrokerColors.primary.withOpacity(.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.45),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: BrokerColors.crocGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          color: BrokerColors.textMain,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    height: 1.45,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: BrokerColors.primary.withOpacity(.09),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: BrokerColors.primary.withOpacity(.18),
                    ),
                  ),
                  child: Text(
                    item.aiNote,
                    style: const TextStyle(
                      color: BrokerColors.textMain,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Anladım',
                      style: TextStyle(
                        color: BrokerColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
