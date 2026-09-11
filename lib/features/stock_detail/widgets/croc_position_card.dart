import 'package:flutter/material.dart';

import '../../../core/position/croc_position_engine.dart';
import '../../../core/position/croc_position_memory_service.dart';

class CrocPositionCard extends StatefulWidget {
  const CrocPositionCard({
    super.key,
    required this.symbol,
    required this.currentPrice,
    required this.masterScore,
    required this.riskLabel,
    required this.stop,
    required this.target,
  });

  final String symbol;
  final double currentPrice;
  final int masterScore;
  final String riskLabel;
  final double stop;
  final double target;

  @override
  State<CrocPositionCard> createState() => _CrocPositionCardState();
}

class _CrocPositionCardState extends State<CrocPositionCard> {
  final TextEditingController _costController = TextEditingController();

  CrocPositionResult? _result;
  CrocPositionMemoryRecord? _memory;
  bool _loadingMemory = true;

  @override
  void initState() {
    super.initState();
    _loadMemory();
  }

  @override
  void didUpdateWidget(covariant CrocPositionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol.toUpperCase() != widget.symbol.toUpperCase()) {
      _result = null;
      _memory = null;
      _costController.clear();
      _loadMemory();
      return;
    }

    if (_memory != null) {
      _evaluateWithMemory();
    }
  }

  @override
  void dispose() {
    _costController.dispose();
    super.dispose();
  }

  Future<void> _loadMemory() async {
    setState(() => _loadingMemory = true);

    final loaded = await const CrocPositionMemoryService().load(widget.symbol);
    if (!mounted) return;

    setState(() {
      _memory = loaded;
      _loadingMemory = false;
      if (loaded != null) {
        _costController.text = loaded.averageCost.toStringAsFixed(2);
      }
    });

    if (loaded != null) {
      _evaluateWithMemory();
    }
  }

  double? _parseCost() {
    final raw = _costController.text.trim().replaceAll(',', '.');
    final value = double.tryParse(raw);
    if (value == null || value <= 0) return null;
    return value;
  }

  void _calculate() {
    final cost = _parseCost();
    if (cost == null) {
      setState(() => _result = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Geçerli bir maliyet gir.')));
      return;
    }

    final lockedStop = _memory?.initialStop ?? widget.stop;
    final lockedTarget = _memory?.initialTarget ?? widget.target;

    setState(() {
      _result = const CrocPositionEngine().evaluate(
        currentPrice: widget.currentPrice,
        averageCost: cost,
        masterScore: widget.masterScore,
        riskLabel: widget.riskLabel,
        stop: lockedStop,
        target: lockedTarget,
      );
    });
  }

  void _evaluateWithMemory() {
    final memory = _memory;
    if (memory == null) return;

    setState(() {
      _result = const CrocPositionEngine().evaluate(
        currentPrice: widget.currentPrice,
        averageCost: memory.averageCost,
        masterScore: widget.masterScore,
        riskLabel: widget.riskLabel,
        stop: memory.initialStop,
        target: memory.initialTarget,
      );
    });
  }

  Future<void> _saveInitialPlan() async {
    final cost = _parseCost();
    if (cost == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce geçerli maliyet gir.')),
      );
      return;
    }

    final stopController = TextEditingController(
      text: widget.stop > 0 ? widget.stop.toStringAsFixed(2) : '',
    );
    final targetController = TextEditingController(
      text: widget.target > 0 ? widget.target.toStringAsFixed(2) : '',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101A17),
          title: const Text(
            'İLK İŞLEM PLANINI KİLİTLE',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.symbol.toUpperCase()} • Maliyet ${cost.toStringAsFixed(2)} TL',
                style: const TextStyle(color: Color(0xFFC5D2CD)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stopController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'İlk stop',
                  hintText: 'Örn. 502.13',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: targetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'İlk ana hedef',
                  hintText: 'Örn. 543.80',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Bu değerler ilk işlem planıdır. Güncel analiz değişse bile sessizce üzerine yazılmaz.',
                style: TextStyle(color: Color(0xFF91A69D), fontSize: 11),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('VAZGEÇ'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('KİLİTLE'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      stopController.dispose();
      targetController.dispose();
      return;
    }

    final stop =
        double.tryParse(stopController.text.trim().replaceAll(',', '.')) ?? 0;
    final target =
        double.tryParse(targetController.text.trim().replaceAll(',', '.')) ?? 0;

    stopController.dispose();
    targetController.dispose();

    if (stop <= 0 || target <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stop ve hedef geçerli olmalı.')),
      );
      return;
    }

    final record = CrocPositionMemoryRecord(
      symbol: widget.symbol.toUpperCase(),
      averageCost: cost,
      initialStop: stop,
      initialTarget: target,
      initialMasterScore: widget.masterScore,
      initialRiskLabel: widget.riskLabel,
      createdAt: DateTime.now(),
    );

    await const CrocPositionMemoryService().save(record);
    if (!mounted) return;

    setState(() => _memory = record);
    _evaluateWithMemory();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.symbol.toUpperCase()} ilk işlem planı kaydedildi.',
        ),
      ),
    );
  }

  Future<void> _deletePlan() async {
    final memory = _memory;
    if (memory == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101A17),
        title: const Text(
          'İlk plan silinsin mi?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '${memory.symbol} için kilitli maliyet/stop/hedef kaydı silinecek.',
          style: const TextStyle(color: Color(0xFFC5D2CD)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('VAZGEÇ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SİL'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await const CrocPositionMemoryService().delete(widget.symbol);
    if (!mounted) return;

    setState(() {
      _memory = null;
      _result = null;
      _costController.clear();
    });
  }

  Color _decisionColor(String decision) {
    if (decision.contains('KÂRI') || decision == 'TUT') {
      return const Color(0xFF70F4AD);
    }
    if (decision.contains('RİSK')) {
      return const Color(0xFFFFC857);
    }
    return const Color(0xFFFF6673);
  }

  String _dateText(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}.${two(date.month)}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final memory = _memory;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1916),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF294039)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'BU HİSSE ELİNDE VAR MI?',
                  style: TextStyle(
                    color: Color(0xFFB8C8C2),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .6,
                  ),
                ),
              ),
              if (_loadingMemory)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            memory == null
                ? 'Maliyetini yaz, CROC pozisyonunu ayrı değerlendirsin.'
                : 'İlk işlem planı kilitli. Güncel analiz ayrı takip edilir.',
            style: const TextStyle(color: Color(0xFF7F938C), fontSize: 11),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _costController,
                  enabled: memory == null,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onSubmitted: (_) => _calculate(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Maliyet (TL)',
                    hintStyle: const TextStyle(color: Color(0xFF667A73)),
                    prefixIcon: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 18,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0A1210),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF294039)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF294039)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (memory == null)
                FilledButton(
                  onPressed: _calculate,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF173F32),
                    foregroundColor: const Color(0xFF70F4AD),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  child: const Text('HESAPLA'),
                )
              else
                FilledButton(
                  onPressed: _evaluateWithMemory,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF173F32),
                    foregroundColor: const Color(0xFF70F4AD),
                  ),
                  child: const Text('GÜNCELLE'),
                ),
            ],
          ),
          if (memory == null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _saveInitialPlan,
                icon: const Icon(Icons.lock_outline, size: 16),
                label: const Text('İLK İŞLEM PLANINI KAYDET'),
              ),
            ),
          ],
          if (memory != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1210),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF294039)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 15,
                        color: Color(0xFF70F4AD),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'İLK İŞLEM PLANI • ${_dateText(memory.createdAt)}',
                          style: const TextStyle(
                            color: Color(0xFF70F4AD),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _deletePlan,
                        child: const Text(
                          'SİL',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _metric('Maliyet', memory.averageCost),
                      _metric('İlk stop', memory.initialStop),
                      _metric('İlk hedef', memory.initialTarget),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'İlk skor ${memory.initialMasterScore}/100 • '
                    '${memory.initialRiskLabel.isEmpty ? 'Risk verisi yok' : memory.initialRiskLabel}',
                    style: const TextStyle(
                      color: Color(0xFF91A69D),
                      fontSize: 10.5,
                    ),
                  ),
                  if (widget.stop > 0 &&
                      (widget.stop - memory.initialStop).abs() > .005) ...[
                    const SizedBox(height: 5),
                    Text(
                      'Güncel analiz stopu ${widget.stop.toStringAsFixed(2)} TL. '
                      'İlk plan stopu ${memory.initialStop.toStringAsFixed(2)} TL olarak korunuyor.',
                      style: const TextStyle(
                        color: Color(0xFFFFC857),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (result != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: _decisionColor(result.decision).withValues(alpha: .08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _decisionColor(result.decision).withValues(alpha: .35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'POZİSYON KARARI',
                        style: TextStyle(
                          color: Color(0xFF91A69D),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${result.pnlPercent >= 0 ? '+' : ''}${result.pnlPercent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: result.pnlPercent >= 0
                              ? const Color(0xFF70F4AD)
                              : const Color(0xFFFF6673),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.decision,
                    style: TextStyle(
                      color: _decisionColor(result.decision),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    result.reason,
                    style: const TextStyle(
                      color: Color(0xFFC5D2CD),
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.actionLine,
                    style: const TextStyle(
                      color: Color(0xFF91A69D),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metric(String label, double value) {
    return Text(
      '$label ${value.toStringAsFixed(2)} TL',
      style: const TextStyle(
        color: Color(0xFFC5D2CD),
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
