import 'package:flutter/material.dart';

import '../models/decision_models.dart';
import '../services/live_decision_engine.dart';
import '../widgets/decision_theme.dart';
import '../widgets/decision_widgets.dart';

class CrocDecisionLabScreen extends StatefulWidget {
  const CrocDecisionLabScreen({super.key});

  @override
  State<CrocDecisionLabScreen> createState() => _CrocDecisionLabScreenState();
}

class _CrocDecisionLabScreenState extends State<CrocDecisionLabScreen> {
  final LiveDecisionEngine _engine = LiveDecisionEngine();

  DecisionSnapshot? _snapshot;
  bool _loading = true;
  String? _error;
  String _selectedCode = 'ASELS';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String? selectedCode}) async {
    final code = (selectedCode ?? _selectedCode).toUpperCase();

    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final snapshot = await _engine.buildSnapshot(selectedCode: code);

      if (!mounted) return;

      setState(() {
        _selectedCode = snapshot.selected.code;
        _snapshot = snapshot;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _selectStock(String code) async {
    _selectedCode = code;
    await _load(selectedCode: code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DecisionTheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF03100B),
        elevation: 0,
        titleSpacing: 18,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CROC AI KARAR MERKEZİ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Tek canlı fiyat kaynağı • mock fiyat yok',
              style: TextStyle(color: DecisionTheme.muted, fontSize: 10),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Canlı veriyi yenile',
            onPressed: _loading ? null : () => _load(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(top: false, child: _body()),
    );
  }

  Widget _body() {
    if (_loading && _snapshot == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _snapshot == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: DecisionTheme.amber,
                size: 38,
              ),
              const SizedBox(height: 12),
              const Text(
                'CANLI VERİ YOK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: DecisionTheme.muted),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _load(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('YENİDEN DENE'),
              ),
            ],
          ),
        ),
      );
    }

    final snapshot = _snapshot;
    if (snapshot == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth < 700 ? 12.0 : 20.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_loading) const LinearProgressIndicator(minHeight: 2),
              if (_loading) const SizedBox(height: 10),
              MarketModeCard(snapshot: snapshot),
              const SizedBox(height: 14),
              const Text(
                'CANLI İNCELENEN HİSSELER',
                style: TextStyle(
                  color: DecisionTheme.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              OpportunityStrip(
                signals: snapshot.opportunities,
                selectedCode: snapshot.selected.code,
                onSelected: _selectStock,
              ),
              const SizedBox(height: 14),
              FinalDecisionCard(signal: snapshot.selected),
              const SizedBox(height: 14),
              const Text(
                'BİRLEŞİK ANALİZ FAKTÖRLERİ',
                style: TextStyle(
                  color: DecisionTheme.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              FactorGrid(factors: snapshot.factors),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF071711),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1D6A4A)),
                ),
                child: const Text(
                  'CANLI VERİ MODU: Fiyat, günlük değişim ve mum verileri CROC Data Gateway üzerinden alınır. '
                  'Veri alınamazsa fiyat uydurulmaz. Kurumsal para ve KAP etkisi gerçek kaynak bağlanana kadar '
                  '0 / veri yok olarak bırakılır.',
                  style: TextStyle(
                    color: Color(0xFF74E7AD),
                    fontSize: 10,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
