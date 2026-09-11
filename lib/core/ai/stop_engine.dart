class StopEngine {
  const StopEngine();

  double calculate(double price, double risk) {
    final percent = 0.03 + (risk / 1000);

    return price * (1 - percent);
  }
}
