import '../models/risk_model.dart';

class RiskEngine {
  const RiskEngine();

  double calculate(RiskModel risk) {
    return risk.total.clamp(0, 100);
  }

  bool isHigh(RiskModel risk) => calculate(risk) >= 70;

  bool isMedium(RiskModel risk) {
    final v = calculate(risk);
    return v >= 40 && v < 70;
  }

  bool isLow(RiskModel risk) => calculate(risk) < 40;
}
