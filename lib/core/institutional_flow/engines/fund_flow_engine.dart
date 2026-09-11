class FundFlowEngine {
  const FundFlowEngine();

  double calculate(String symbol) {
    final int seed = symbol.codeUnits.fold<int>(
      0,
      (int total, int value) => total + value,
    );

    return ((seed % 18) - 4) / 2.0;
  }
}
