import 'croc_akd_csv_parser.dart';
import 'croc_institutional_strength_engine.dart';

/// Historical AKD is kept separate from the live verified flow store.
/// Importing a CSV must never activate a real-time AKD badge.
class CrocAkdHistoricalArchive {
  final Map<String, Map<DateTime, List<CrocParticipantFlow>>> _data = {};

  bool importNormalizedCsv({
    required String symbol,
    required DateTime tradingDate,
    required String csv,
  }) {
    final ticker = symbol.trim().toUpperCase();
    if (!RegExp(r'^[A-Z0-9]{3,8}$').hasMatch(ticker)) return false;
    final date = DateTime.utc(
      tradingDate.year,
      tradingDate.month,
      tradingDate.day,
    );
    if (date.isAfter(DateTime.now().toUtc())) return false;
    final rows = const CrocAkdCsvParser().parse(csv);
    if (rows == null) return false;
    final unique = <String>{};
    for (final row in rows) {
      if (!unique.add(row.participant.trim().toUpperCase())) return false;
    }
    _data.putIfAbsent(ticker, () => {})[date] = rows;
    return true;
  }

  List<CrocParticipantFlow> rows(String symbol, DateTime tradingDate) {
    final date = DateTime.utc(
      tradingDate.year,
      tradingDate.month,
      tradingDate.day,
    );
    return _data[symbol.trim().toUpperCase()]?[date] ?? const [];
  }

  /// Historical daily broker totals. Never interpreted as a live signal.
  CrocAkdHistoricalSummary? summary(String symbol, DateTime tradingDate) {
    final records = rows(symbol, tradingDate);
    if (records.isEmpty) return null;
    var buy = 0.0;
    var sell = 0.0;
    for (final record in records) {
      buy += record.buyLots;
      sell += record.sellLots;
    }
    if (!buy.isFinite || !sell.isFinite) return null;
    final ordered = List<CrocParticipantFlow>.of(records)
      ..sort((a, b) => b.netLots.compareTo(a.netLots));
    return CrocAkdHistoricalSummary(
      tradingDate: DateTime.utc(
        tradingDate.year,
        tradingDate.month,
        tradingDate.day,
      ),
      participantCount: records.length,
      totalBuyLots: buy,
      totalSellLots: sell,
      topNetBuyer: ordered.first.netLots > 0 ? ordered.first : null,
      topNetSeller: ordered.last.netLots < 0 ? ordered.last : null,
    );
  }

  void clear() => _data.clear();
}

/// Descriptive totals for imported historical rows only.
/// Net totals do not establish market-wide institutional money flows.
class CrocAkdHistoricalSummary {
  final DateTime tradingDate;
  final int participantCount;
  final double totalBuyLots;
  final double totalSellLots;
  final CrocParticipantFlow? topNetBuyer;
  final CrocParticipantFlow? topNetSeller;

  const CrocAkdHistoricalSummary({
    required this.tradingDate,
    required this.participantCount,
    required this.totalBuyLots,
    required this.totalSellLots,
    required this.topNetBuyer,
    required this.topNetSeller,
  });

  double get netLots => totalBuyLots - totalSellLots;
}
