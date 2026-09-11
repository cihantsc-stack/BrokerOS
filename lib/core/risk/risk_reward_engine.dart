import '../scenario/market_scenario.dart';
import '../scenario/scenario_engine.dart';
import '../scenario/scenario_snapshot.dart';
import 'risk_reward_snapshot.dart';

class RiskRewardEngine {
  RiskRewardEngine._();

  static final RiskRewardEngine instance = RiskRewardEngine._();

  Future<RiskRewardSnapshot> analyze(String symbol) async {
    final ScenarioSnapshot scenario = await ScenarioEngine.instance.simulate(
      symbol,
    );

    final MarketScenario bullish = scenario.scenarios.firstWhere(
      (MarketScenario item) => item.type == MarketScenarioType.bullish,
    );
    final MarketScenario bearish = scenario.scenarios.firstWhere(
      (MarketScenario item) => item.type == MarketScenarioType.bearish,
    );

    final double risk = bearish.minReturnPercent.abs().clamp(0.5, 10.0);
    final double reward = bullish.maxReturnPercent.clamp(0.5, 15.0);
    final double ratio = reward / risk;

    return RiskRewardSnapshot(
      symbol: symbol,
      riskScore: (risk * 10).clamp(0.0, 100.0),
      rewardScore: (reward * 10).clamp(0.0, 100.0),
      ratio: ratio,
      stopPercent: bearish.minReturnPercent,
      firstTargetPercent: bullish.minReturnPercent,
      secondTargetPercent: bullish.maxReturnPercent,
      strategy: ratio >= 1.6
          ? 'PARÇALI ALIM'
          : ratio >= 1.1
          ? 'TEMKİNLİ İZLE'
          : 'BEKLE',
      aiComment: ratio >= 1.6
          ? 'Beklenen ödül riske göre güçlü. Pozisyon tek seferde '
                'değil, iki veya üç kademe halinde kurulmalı.'
          : 'Risk ve ödül dengesi henüz yeterince güçlü değil. '
                'Yeni teyit gelmeden pozisyon büyütülmemeli.',
    );
  }
}
