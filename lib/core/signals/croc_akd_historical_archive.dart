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

  void clear() => _data.clear();
}
