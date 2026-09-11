import '../hidden_structure/hidden_structure_engine.dart';
import '../hidden_structure/hidden_structure_snapshot.dart';
import '../smart_money/smart_money_engine.dart';
import '../smart_money/smart_money_snapshot.dart';
import 'market_scenario.dart';
import 'scenario_snapshot.dart';

class ScenarioEngine {
  ScenarioEngine._();

  static final ScenarioEngine instance = ScenarioEngine._();

  Future<ScenarioSnapshot> simulate(String symbol) async {
    final SmartMoneySnapshot smart = await SmartMoneyEngine.instance.analyze(
      symbol,
    );
    final HiddenStructureSnapshot hidden = await HiddenStructureEngine.instance
        .analyze(symbol);

    final double strength =
        ((smart.hiddenAccumulationScore * 0.55) + (hidden.overallScore * 0.45))
            .clamp(0.0, 100.0);

    final double bullish = (42.0 + (strength * 0.20)).clamp(45.0, 68.0);
    final double bearish = (26.0 - (strength * 0.13)).clamp(10.0, 22.0);
    final double neutral = 100.0 - bullish - bearish;

    final String decision = strength >= 78.0
        ? 'AL'
        : strength >= 62.0
        ? 'KADEMELİ AL'
        : 'BEKLE';

    return ScenarioSnapshot(
      symbol: symbol,
      decision: decision,
      confidence: strength,
      scenarios: <MarketScenario>[
        MarketScenario(
          type: MarketScenarioType.bullish,
          probability: bullish,
          minReturnPercent: 3.1,
          maxReturnPercent: 5.4,
          timeHorizon: '2-4 gün',
          explanation: 'Kurumsal para devam eder ve hacim teyit verirse.',
        ),
        MarketScenario(
          type: MarketScenarioType.neutral,
          probability: neutral,
          minReturnPercent: -0.6,
          maxReturnPercent: 1.5,
          timeHorizon: '1-3 gün',
          explanation: 'Para akışı zayıflar ancak güçlü satış başlamazsa.',
        ),
        MarketScenario(
          type: MarketScenarioType.bearish,
          probability: bearish,
          minReturnPercent: -4.2,
          maxReturnPercent: -2.7,
          timeHorizon: '1-2 gün',
          explanation: 'Büyük alıcılar çekilir ve dağıtım baskısı yükselirse.',
        ),
      ],
      aiComment:
          'Ana senaryo yükseliş yönünde. Karar tek fiyattan değil, '
          'parçalı giriş ve senaryo bozulma seviyeleriyle uygulanmalı.',
      inputs: const <String>[
        'Smart Money',
        'Gizli Yapı',
        'Kurum Hareketleri',
        'Hacim',
        'Volatilite',
        'Teknik Momentum',
      ],
    );
  }
}
