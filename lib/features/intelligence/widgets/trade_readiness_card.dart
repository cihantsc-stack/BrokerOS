import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class TradeReadinessCard extends StatefulWidget {
  final StockAnalysis stock;

  const TradeReadinessCard({super.key, required this.stock});

  @override
  State<TradeReadinessCard> createState() => _TradeReadinessCardState();
}

class _TradeReadinessCardState extends State<TradeReadinessCard> {
  bool _entryKnown = false;
  bool _stopAccepted = false;
  bool _amountPlanned = false;
  bool _notChasing = false;

  bool get _isReady =>
      _entryKnown && _stopAccepted && _amountPlanned && _notChasing;

  int get _completedCount => [
    _entryKnown,
    _stopAccepted,
    _amountPlanned,
    _notChasing,
  ].where((item) => item).length;

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İŞLEME HAZIR MIYIM?',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Alım yapmadan önce dört basit kontrolü tamamla.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.35),
          ),
          const SizedBox(height: 14),
          _CheckRow(
            value: _entryKnown,
            title: 'Giriş fiyatımı biliyorum',
            explanation:
                'Planlanan giriş: ${widget.stock.entry.toStringAsFixed(2)} ₺',
            onChanged: (value) {
              setState(() {
                _entryKnown = value;
              });
            },
          ),
          _CheckRow(
            value: _stopAccepted,
            title: 'Zarar sınırını kabul ediyorum',
            explanation:
                'Plan bozulma seviyesi: ${widget.stock.stop.toStringAsFixed(2)} ₺',
            onChanged: (value) {
              setState(() {
                _stopAccepted = value;
              });
            },
          ),
          _CheckRow(
            value: _amountPlanned,
            title: 'Ne kadar alacağımı belirledim',
            explanation:
                'Bütün parayla değil, planlanan miktarla işlem yapacağım.',
            onChanged: (value) {
              setState(() {
                _amountPlanned = value;
              });
            },
          ),
          _CheckRow(
            value: _notChasing,
            title: 'Fiyatın peşinden koşmayacağım',
            explanation:
                'Fiyat yükselmişse aceleyle almak yerine uygun bölgeyi bekleyeceğim.',
            onChanged: (value) {
              setState(() {
                _notChasing = value;
              });
            },
          ),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: (_isReady ? BrokerColors.green : BrokerColors.primary)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: (_isReady ? BrokerColors.green : BrokerColors.primary)
                    .withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isReady ? Icons.verified_rounded : Icons.fact_check_outlined,
                  color: _isReady ? BrokerColors.green : BrokerColors.primary,
                  size: 31,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isReady
                            ? 'PLANI TAMAMLADIN'
                            : '$_completedCount / 4 KONTROL TAMAM',
                        style: TextStyle(
                          color: _isReady
                              ? BrokerColors.green
                              : BrokerColors.primary,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isReady
                            ? 'İşlem kararın artık duyguyla değil, önceden belirlenmiş bir planla ilerliyor.'
                            : 'Eksik kontrolleri tamamlamadan işlem açmak gereksiz risk oluşturabilir.',
                        style: const TextStyle(
                          color: BrokerColors.textMain,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Bu kontrol listesi yatırım tavsiyesi değildir; plansız ve duygusal işlemleri azaltmaya yardımcı olur.',
            style: TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 10,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final bool value;
  final String title;
  final String explanation;
  final ValueChanged<bool> onChanged;

  const _CheckRow({
    required this.value,
    required this.title,
    required this.explanation,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (value ? BrokerColors.green : BrokerColors.primary).withValues(
            alpha: value ? 0.07 : 0.035,
          ),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: (value ? BrokerColors.green : BrokerColors.primary)
                .withValues(alpha: value ? 0.20 : 0.09),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: (checked) {
                onChanged(checked ?? false);
              },
              activeColor: BrokerColors.green,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: value
                            ? BrokerColors.green
                            : BrokerColors.textMain,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      explanation,
                      style: const TextStyle(
                        color: BrokerColors.textSoft,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
