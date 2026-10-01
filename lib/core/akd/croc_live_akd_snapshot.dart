class CrocLiveAkdNetRow {
  const CrocLiveAkdNetRow({
    required this.institution,
    required this.netLots,
  });

  final String institution;
  final double netLots;
}

class CrocLiveAkdSnapshot {
  const CrocLiveAkdSnapshot({
    required this.symbol,
    required this.rows,
    required this.positiveNetLots,
    required this.negativeNetLots,
    required this.netBookImbalancePercent,
  });

  final String symbol;
  final List<CrocLiveAkdNetRow> rows;
  final double positiveNetLots;
  final double negativeNetLots;
  final double netBookImbalancePercent;

  bool get isBalanced =>
      rows.isNotEmpty &&
      positiveNetLots > 0 &&
      negativeNetLots > 0 &&
      netBookImbalancePercent <= 1.0;
}

/// Normalizes the two Matriks Sayfa9 rankings into one signed net-lot book.
///
/// Sayfa9 exposes the same participant universe from opposite rankings:
/// A/B is buyer-ranked and E/F is seller-ranked. Near zero, the rankings
/// overlap, so appending both lists would double count participants.
/// This parser deduplicates by normalized institution name and rejects
/// conflicting duplicate net-lot values instead of guessing.
class CrocLiveAkdSnapshotParser {
  const CrocLiveAkdSnapshotParser({this.duplicateToleranceLots = 1.0});

  final double duplicateToleranceLots;

  CrocLiveAkdSnapshot? parse({
    required String symbol,
    required Iterable<CrocLiveAkdNetRow> buyerRanking,
    required Iterable<CrocLiveAkdNetRow> sellerRanking,
  }) {
    final normalizedSymbol = symbol.trim().toUpperCase();
    if (!RegExp(r'^[A-Z0-9]{3,8}$').hasMatch(normalizedSymbol)) return null;
    if (!duplicateToleranceLots.isFinite || duplicateToleranceLots < 0) {
      return null;
    }

    final byInstitution = <String, double>{};

    for (final row in [...buyerRanking, ...sellerRanking]) {
      final name = row.institution.trim().toUpperCase();
      final net = row.netLots;
      if (name.isEmpty || name == 'XXX' || !net.isFinite || net == 0) {
        continue;
      }

      final previous = byInstitution[name];
      if (previous != null) {
        if ((previous - net).abs() > duplicateToleranceLots) return null;
        continue;
      }
      byInstitution[name] = net;
    }

    if (byInstitution.isEmpty) return null;

    final rows = byInstitution.entries
        .map(
          (entry) => CrocLiveAkdNetRow(
            institution: entry.key,
            netLots: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) => b.netLots.compareTo(a.netLots));

    var positive = 0.0;
    var negative = 0.0;
    for (final row in rows) {
      if (row.netLots > 0) {
        positive += row.netLots;
      } else {
        negative += row.netLots.abs();
      }
    }

    final base = positive > negative ? positive : negative;
    final imbalance =
        base > 0 ? ((positive - negative).abs() / base) * 100 : 100.0;

    return CrocLiveAkdSnapshot(
      symbol: normalizedSymbol,
      rows: List.unmodifiable(rows),
      positiveNetLots: positive,
      negativeNetLots: negative,
      netBookImbalancePercent: imbalance,
    );
  }
}
