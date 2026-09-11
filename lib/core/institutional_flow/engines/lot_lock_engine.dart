class LotLockEngine {
  const LotLockEngine();

  double calculate(String symbol) {
    final int seed = symbol.codeUnits.fold<int>(
      0,
      (int total, int value) => total + value,
    );

    return 38 + (seed % 51).toDouble();
  }
}
