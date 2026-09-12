import 'package:flutter/material.dart';

import '../../../core/analysis/croc_technical_analysis.dart';
import '../../../core/kap_intelligence/kap_intelligence_service.dart';
import '../../../core/master_engine/croc_master_stock_engine.dart';
import '../../../core/trade/croc_horizon_engine.dart';

class CrocQuickViewCard extends StatefulWidget {
  final double price;
  final CrocTechnicalAnalysis? technical;
  final CrocMasterStockResult? master;
  final KapIntelligenceResult kap;

  const CrocQuickViewCard({
    super.key,
    required this.price,
    required this.technical,
    required this.master,
    required this.kap,
  });

  @override
  State<CrocQuickViewCard> createState() => _CrocQuickViewCardState();
}

class _CrocQuickViewCardState extends State<CrocQuickViewCard> {
  CrocHorizon _selected = CrocHorizon.week;

  @override
  Widget build(BuildContext context) {
    final results = const CrocHorizonEngine().evaluate(
      price: widget.price,
      technical: widget.technical,
      master: widget.master,
      kap: widget.kap,
    );
    final current = results.firstWhere((item) => item.horizon == _selected);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF06130F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1D5A41)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.bolt_rounded,
                color: Color(0xFF70F4AD),
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'CROC HIZLI GÖRÜŞ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Tüyo aldığın hisseyi vadeye göre hızlıca süz.',
            style: TextStyle(
              color: Color(0xFF8FA79D),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: results.map((item) {
                final selected = item.horizon == _selected;
                return Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _selected = item.horizon),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF123A2A)
                            : const Color(0xFF081A14),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF70F4AD)
                              : const Color(0xFF1B4636),
                        ),
                      ),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: selected
                              ? const Color(0xFF70F4AD)
                              : const Color(0xFF9AAEA5),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(growable: false),
            ),
          ),
          const SizedBox(height: 12),
          _DecisionStrip(result: current),
          const SizedBox(height: 10),
          _LevelGrid(result: current),
          const SizedBox(height: 10),
          ...current.reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.circle,
                      size: 5,
                      color: Color(0xFF70F4AD),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(
                        color: Color(0xFFB5C4BE),
                        fontSize: 10,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (current.missingLayers.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              'Eksik katman: ${current.missingLayers.join(' • ')}',
              style: const TextStyle(
                color: Color(0xFFFFC66D),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DecisionStrip extends StatelessWidget {
  final CrocHorizonResult result;

  const _DecisionStrip({required this.result});

  @override
  Widget build(BuildContext context) {
    final tone = switch (result.decision) {
      'AL' => const Color(0xFF70F4AD),
      'İZLE' => const Color(0xFF8FD8FF),
      'BEKLE' => const Color(0xFFFFC857),
      'UZAK DUR' => const Color(0xFFFF6673),
      _ => const Color(0xFF91A69D),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.withValues(alpha: .24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.label,
                  style: const TextStyle(
                    color: Color(0xFF8FA79D),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  result.decision,
                  style: TextStyle(
                    color: tone,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          _MiniStat(label: 'SKOR', value: '${result.score}/100'),
          const SizedBox(width: 8),
          _MiniStat(label: 'GÜVEN', value: '%${result.confidence}'),
        ],
      ),
    );
  }
}

class _LevelGrid extends StatelessWidget {
  final CrocHorizonResult result;

  const _LevelGrid({required this.result});

  String _price(double? value) => value == null ? '—' : value.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final entry = result.entryLow == null || result.entryHigh == null
        ? '—'
        : '${_price(result.entryLow)}–${_price(result.entryHigh)}';
    final targets = [result.target1, result.target2, result.target3]
        .whereType<double>()
        .map((value) => value.toStringAsFixed(2))
        .join(' / ');

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _LevelBox(label: 'GİRİŞ', value: entry),
        _LevelBox(label: 'STOP', value: _price(result.stop)),
        _LevelBox(label: 'HEDEFLER', value: targets.isEmpty ? '—' : targets),
      ],
    );
  }
}

class _LevelBox extends StatelessWidget {
  final String label;
  final String value;

  const _LevelBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF081A14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1B4636)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF789086),
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF07120F),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFF173E30)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF71877D),
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
