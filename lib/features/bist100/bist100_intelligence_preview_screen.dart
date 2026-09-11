import 'package:flutter/material.dart';

import '../../core/bist/data/bist100_batch_data_source.dart';
import '../../core/bist/services/bist100_live_intelligence_service.dart';
import 'widgets/bist100_intelligence_card.dart';

class Bist100IntelligencePreviewScreen extends StatelessWidget {
  final String apiKey;

  const Bist100IntelligencePreviewScreen({super.key, required this.apiKey});

  @override
  Widget build(BuildContext context) {
    final Bist100LiveIntelligenceService service =
        Bist100LiveIntelligenceService(
          dataSource: Bist100BatchDataSource(apiKey: apiKey),
        );

    return Scaffold(
      backgroundColor: const Color(0xFF070B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B12),
        foregroundColor: Colors.white,
        title: const Text('CROC AI — BIST 100'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Bist100IntelligenceCard(service: service),
      ),
    );
  }
}
