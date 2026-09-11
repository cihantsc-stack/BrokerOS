class ForeignRatioEngine {
  const ForeignRatioEngine();

  double calculate(String symbol) {
    final int seed = symbol.codeUnits.fold<int>(
      0,
      (int total, int value) => total + value,
    );

    return 32 + (seed % 39).toDouble();
  }
}
