import '../data/bist100_batch_data_source.dart';
import 'bist100_intelligence_service.dart';

class Bist100LiveIntelligenceResult {
  final Bist100BatchResult marketData;
  final Bist100IntelligenceResult intelligence;

  const Bist100LiveIntelligenceResult({
    required this.marketData,
    required this.intelligence,
  });
}

class Bist100LiveIntelligenceService {
  final Bist100BatchDataSource dataSource;
  final Bist100IntelligenceService intelligenceService;

  const Bist100LiveIntelligenceService({
    required this.dataSource,
    this.intelligenceService = const Bist100IntelligenceService(),
  });

  Future<Bist100LiveIntelligenceResult> load({
    bool forceRefresh = false,
  }) async {
    final Bist100BatchResult marketData = await dataSource.fetch(
      forceRefresh: forceRefresh,
    );

    return Bist100LiveIntelligenceResult(
      marketData: marketData,
      intelligence: intelligenceService.analyze(marketData.ticks),
    );
  }
}
