import 'croc_akd_models.dart';

class CrocAkdEngine {
  const CrocAkdEngine({
    this.topCount = 5,
    this.distortionTurnoverThresholdPercent = 60,
    this.netBookTolerancePercent = 1,
  });

  final int topCount;

  /// If this share of total turnover comes from rows where either buy or sell
  /// side is effectively absent, concentration is not treated as directional
  /// AKD evidence. This protects cases such as repeated limit-lock sessions.
  final double distortionTurnoverThresholdPercent;

  /// Positive and negative broker net lots should balance in a complete AKD
  /// export. Larger gaps mean the table is partial/truncated and directional
  /// concentration must not be trusted.
  final double netBookTolerancePercent;

  CrocAkdResult analyze(Iterable<CrocAkdBrokerRow> source) {
    if (topCount < 1) {
      throw ArgumentError.value(topCount, 'topCount', 'must be at least 1');
    }
    if (!distortionTurnoverThresholdPercent.isFinite ||
        distortionTurnoverThresholdPercent < 0 ||
        distortionTurnoverThresholdPercent > 100) {
      throw ArgumentError.value(
        distortionTurnoverThresholdPercent,
        'distortionTurnoverThresholdPercent',
        'must be between 0 and 100',
      );
    }

    if (!netBookTolerancePercent.isFinite ||
        netBookTolerancePercent < 0 ||
        netBookTolerancePercent > 100) {
      throw ArgumentError.value(
        netBookTolerancePercent,
        'netBookTolerancePercent',
        'must be between 0 and 100',
      );
    }

    final rows = source.where((r) => r.isUsable).toList(growable: false);
    final buyers = rows.where((r) => r.netLots > 0).toList()
      ..sort((a, b) => b.netLots.compareTo(a.netLots));
    final sellers = rows.where((r) => r.netLots < 0).toList()
      ..sort((a, b) => a.netLots.compareTo(b.netLots));

    final topBuyers = buyers.take(topCount).toList(growable: false);
    final topSellers = sellers.take(topCount).toList(growable: false);
    final positive = _sum(buyers.map((r) => r.netLots));
    final negative = _sum(sellers.map((r) => r.netLots.abs()));
    final netBookBase = positive > negative ? positive : negative;
    final netBookImbalancePct = _percent((positive - negative).abs(), netBookBase);
    final balancedNetBook = netBookBase > 0 && netBookImbalancePct <= netBookTolerancePercent;
    final buyerPct =
        _percent(_sum(topBuyers.map((r) => r.netLots)), positive);
    final sellerPct =
        _percent(_sum(topSellers.map((r) => r.netLots.abs())), negative);

    final byTurnover = rows.toList()
      ..sort((a, b) => b.totalLots.compareTo(a.totalLots));
    final turnover = _sum(rows.map((r) => r.totalLots));
    final turnoverPct = _percent(
      _sum(byTurnover.take(topCount).map((r) => r.totalLots)),
      turnover,
    );
    final oneSidedTurnover = _sum(
      rows
          .where((r) => r.dataFlags.contains(CrocAkdDataFlag.oneSidedFlow))
          .map((r) => r.totalLots),
    );
    final oneSidedPct = _percent(oneSidedTurnover, turnover);
    final distorted =
        turnover > 0 && oneSidedPct >= distortionTurnoverThresholdPercent;

    final gap = buyerPct - sellerPct;
    final signal = rows.isEmpty || !balancedNetBook
        ? CrocAkdConcentrationSignal.insufficientData
        : distorted
            ? CrocAkdConcentrationSignal.distorted
            : gap >= 10
            ? CrocAkdConcentrationSignal.buyerConcentrated
                : gap <= -10
                    ? CrocAkdConcentrationSignal.sellerConcentrated
                    : CrocAkdConcentrationSignal.balanced;

    return CrocAkdResult(
      rows: List.unmodifiable(rows),
      topBuyers: List.unmodifiable(topBuyers),
      topSellers: List.unmodifiable(topSellers),
      positiveNetLots: positive,
      negativeNetLots: negative,
      buyerConcentrationPercent: buyerPct,
      sellerConcentrationPercent: sellerPct,
      turnoverConcentrationPercent: turnoverPct,
      oneSidedTurnoverPercent: oneSidedPct,
      isFlowDistorted: distorted,
      isBalancedNetBook: balancedNetBook,
      netBookImbalancePercent: netBookImbalancePct,
      signal: signal,
    );
  }

  double _sum(Iterable<double> values) =>
      values.fold(0, (sum, value) => sum + value);

  double _percent(double part, double whole) =>
      whole > 0 ? (part / whole) * 100 : 0;
}
