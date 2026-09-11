import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';

class BeginnerStockHeader extends StatelessWidget {
  final StockAnalysis stock;

  const BeginnerStockHeader({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final double price = stock.lastPrice ?? stock.entry;
    final double change = stock.dailyChange ?? 0;
    final bool positive = change >= 0;
    final Color tone = positive ? BrokerColors.green : BrokerColors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: BrokerColors.primary.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              stock.symbol.substring(
                0,
                stock.symbol.length >= 2 ? 2 : stock.symbol.length,
              ),
              style: TextStyle(
                color: tone,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stock.symbol,
                  style: const TextStyle(
                    color: BrokerColors.textMain,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stock.company,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: BrokerColors.textSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${price.toStringAsFixed(2)} ₺',
                style: const TextStyle(
                  color: BrokerColors.textMain,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${positive ? '+' : ''}${change.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: tone,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
