import '../models/flow_context_input.dart';
import '../models/flow_context_result.dart';
import 'absorption_engine.dart';

class FlowContextEngine {
  final AbsorptionEngine absorptionEngine;

  const FlowContextEngine({this.absorptionEngine = const AbsorptionEngine()});

  FlowContextResult evaluate(FlowContextInput input) {
    if (!input.institutionalDataAvailable) {
      return FlowContextResult.dataWaiting(
        symbol: input.symbol,
        generatedAt: DateTime.now(),
      );
    }

    final absorption = absorptionEngine.evaluate(input);

    final observations = <String>[];

    final hasNetSelling = input.brokers.any((item) => item.netLot < 0);
    final hasNetBuying = input.brokers.any((item) => item.netLot > 0);

    if (hasNetSelling) {
      observations.add('Kurumsal satis akisi mevcut.');
    }

    if (hasNetBuying) {
      observations.add('Kurumsal alim akisi mevcut.');
    }

    if (input.fundDataAvailable) {
      final knownChanges = input.fundChanges
          .where((item) => item.lotChange != null)
          .toList();

      final reducingFunds = knownChanges
          .where((item) => item.lotChange! < 0)
          .length;
      final increasingFunds = knownChanges
          .where((item) => item.lotChange! > 0)
          .length;

      observations.add(
        'Fon pozisyon degisimi: $increasingFunds artiran / $reducingFunds azaltan.',
      );
    } else {
      observations.add('Fon pozisyon verisi bekleniyor.');
    }

    if (!input.crossAssetDataAvailable) {
      observations.add('Cross-asset baglami dogrulanmadi.');
    }

    final FlowContextState state;
    String summary;
    int confidence;

    if (absorption.available &&
        absorption.score != null &&
        absorption.score! >= 75) {
      state = FlowContextState.possibleAbsorption;
      summary =
          'Satis baskisi mevcut; guclu karsi alim nedeniyle absorpsiyon ihtimali var. '
          'Bu tek basina AL sinyali degildir.';
      confidence = 65;
    } else if (hasNetSelling && hasNetBuying) {
      state = FlowContextState.mixed;
      summary =
          'Kurumsal alim ve satis birlikte goruluyor. Dagitim veya birikim sonucu icin ek teyit gerekli.';
      confidence = 50;
    } else if (hasNetSelling) {
      state = FlowContextState.sellingPressure;
      summary =
          'Kurumsal satis baskisi goruluyor. Satisin nedeni mevcut verilerle dogrulanamadi.';
      confidence = 45;
    } else {
      state = FlowContextState.neutral;
      summary = 'Belirgin kurumsal satis/alim baglami olusmadi.';
      confidence = 35;
    }

    return FlowContextResult(
      symbol: input.symbol,
      state: state,
      absorption: absorption,
      confidence: confidence,
      summary: summary,
      observations: List<String>.unmodifiable(observations),
      affectsMasterDecision: false,
      generatedAt: DateTime.now(),
    );
  }
}
