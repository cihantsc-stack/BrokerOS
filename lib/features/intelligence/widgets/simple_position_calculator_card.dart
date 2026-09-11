import 'package:flutter/material.dart';

import '../../../core/models/stock_analysis.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

class SimplePositionCalculatorCard extends StatefulWidget {
  final StockAnalysis stock;

  const SimplePositionCalculatorCard({super.key, required this.stock});

  @override
  State<SimplePositionCalculatorCard> createState() =>
      _SimplePositionCalculatorCardState();
}

class _SimplePositionCalculatorCardState
    extends State<SimplePositionCalculatorCard> {
  final TextEditingController _portfolioController = TextEditingController();
  final TextEditingController _riskPercentController = TextEditingController(
    text: '1',
  );

  String? _errorMessage;
  _PositionResult? _result;

  @override
  void dispose() {
    _portfolioController.dispose();
    _riskPercentController.dispose();
    super.dispose();
  }

  void _calculate() {
    final double? portfolio = _parseNumber(_portfolioController.text);
    final double? riskPercent = _parseNumber(_riskPercentController.text);

    if (portfolio == null || portfolio <= 0) {
      setState(() {
        _errorMessage = 'Toplam yatırım tutarını yaz.';
        _result = null;
      });
      return;
    }

    if (riskPercent == null || riskPercent <= 0 || riskPercent > 10) {
      setState(() {
        _errorMessage = 'Risk oranını %0 ile %10 arasında yaz.';
        _result = null;
      });
      return;
    }

    final double riskPerShare = widget.stock.entry - widget.stock.stop;

    if (riskPerShare <= 0) {
      setState(() {
        _errorMessage =
            'Giriş ve zarar sınırı verileri hesaplamaya uygun değil.';
        _result = null;
      });
      return;
    }

    final double maximumLoss = portfolio * (riskPercent / 100);
    final int quantity = (maximumLoss / riskPerShare).floor();
    final double requiredMoney = quantity * widget.stock.entry;
    final double portfolioShare = portfolio == 0
        ? 0
        : (requiredMoney / portfolio) * 100;

    setState(() {
      _errorMessage = null;
      _result = _PositionResult(
        maximumLoss: maximumLoss,
        quantity: quantity,
        requiredMoney: requiredMoney,
        portfolioShare: portfolioShare,
      );
    });
  }

  double? _parseNumber(String raw) {
    final String normalized = raw
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '.');

    return double.tryParse(normalized);
  }

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NE KADAR ALMALIYIM?',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Kaybetmeyi göze aldığın tutara göre yaklaşık adet hesapla.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.35),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _portfolioController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w800,
            ),
            decoration: _inputDecoration(
              label: 'Toplam yatırım paran',
              hint: 'Örnek: 100.000',
              suffix: '₺',
              icon: Icons.account_balance_wallet_outlined,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _riskPercentController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w800,
            ),
            decoration: _inputDecoration(
              label: 'Bu işlemde kabul ettiğin zarar',
              hint: 'Örnek: 1',
              suffix: '%',
              icon: Icons.shield_outlined,
            ),
          ),
          const SizedBox(height: 11),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate_rounded),
              label: const Text('Güvenli adedi hesapla'),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 9),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: BrokerColors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 14),
            _ResultPanel(stock: widget.stock, result: _result!),
          ],
          const SizedBox(height: 10),
          const Text(
            'Bu hesap, zarar sınırına ulaşıldığında oluşabilecek yaklaşık kayba göre yapılır. '
            'Komisyon, kayma ve ani fiyat hareketleri dahil değildir.',
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

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required String suffix,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffix,
      prefixIcon: Icon(icon, color: BrokerColors.primary),
      filled: true,
      fillColor: BrokerColors.primary.withValues(alpha: 0.04),
      labelStyle: const TextStyle(color: BrokerColors.textSoft),
      hintStyle: const TextStyle(color: BrokerColors.textSoft),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: BrokerColors.primary.withValues(alpha: 0.14),
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final StockAnalysis stock;
  final _PositionResult result;

  const _ResultPanel({required this.stock, required this.result});

  @override
  Widget build(BuildContext context) {
    final bool tooLarge = result.portfolioShare > 35;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: BrokerColors.green.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: BrokerColors.green.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          _ResultLine(
            title: 'Yaklaşık adet',
            value: '${result.quantity} lot',
            tone: BrokerColors.green,
          ),
          _ResultLine(
            title: 'Yaklaşık işlem tutarı',
            value: '${result.requiredMoney.toStringAsFixed(0)} ₺',
            tone: BrokerColors.primary,
          ),
          _ResultLine(
            title: 'En fazla planlanan kayıp',
            value: '${result.maximumLoss.toStringAsFixed(0)} ₺',
            tone: BrokerColors.red,
          ),
          _ResultLine(
            title: 'Portföydeki payı',
            value: '%${result.portfolioShare.toStringAsFixed(1)}',
            tone: tooLarge ? BrokerColors.red : BrokerColors.green,
          ),
          const Divider(),
          Text(
            result.quantity <= 0
                ? 'Bu risk sınırıyla en az 1 lot için yeterli alan oluşmuyor.'
                : tooLarge
                ? 'Dikkat: Bu işlem portföyün büyük bölümünü kullanıyor. Daha küçük pozisyon düşün.'
                : '${stock.symbol} için hesaplanan miktar portföy dağılımı açısından daha kontrollü görünüyor.',
            style: TextStyle(
              color: tooLarge ? BrokerColors.red : BrokerColors.textMain,
              height: 1.4,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  final String title;
  final String value;
  final Color tone;

  const _ResultLine({
    required this.title,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: BrokerColors.textSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: tone, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _PositionResult {
  final double maximumLoss;
  final int quantity;
  final double requiredMoney;
  final double portfolioShare;

  const _PositionResult({
    required this.maximumLoss,
    required this.quantity,
    required this.requiredMoney,
    required this.portfolioShare,
  });
}
