import '../models/broker_flow.dart';

class ConcentrationEngine {
  const ConcentrationEngine();

  double calculate(List<BrokerFlow> brokers) {
    final double total = brokers.fold<double>(
      0,
      (double sum, BrokerFlow item) => sum + item.marketShare.abs(),
    );

    if (total == 0) {
      return 0;
    }

    final double topThree = brokers
        .take(3)
        .fold<double>(
          0,
          (double sum, BrokerFlow item) => sum + item.marketShare.abs(),
        );

    return (topThree / total) * 100;
  }
}
