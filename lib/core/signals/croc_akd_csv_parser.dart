import 'croc_institutional_strength_engine.dart';

/// Parses a normalized export, not a vendor-specific Matriks file.
/// The calling adapter must independently establish data provenance.
class CrocAkdCsvParser {
  const CrocAkdCsvParser();

  List<CrocParticipantFlow>? parse(String input) {
    final lines = input.replaceAll('\r', '').trim().split('\n');
    if (lines.length < 2 ||
        lines.first.trim().toLowerCase() != 'participant,buy_lots,sell_lots') {
      return null;
    }
    final rows = <CrocParticipantFlow>[];
    for (final line in lines.skip(1)) {
      if (line.trim().isEmpty) continue;
      final cells = line.split(',');
      if (cells.length != 3) return null;
      final buy = double.tryParse(cells[1].trim());
      final sell = double.tryParse(cells[2].trim());
      if (cells[0].trim().isEmpty || buy == null || sell == null ||
          !buy.isFinite || !sell.isFinite || buy < 0 || sell < 0) {
        return null;
      }
      rows.add(CrocParticipantFlow(
        participant: cells[0].trim(),
        buyLots: buy,
        sellLots: sell,
      ));
    }
    return rows.isEmpty ? null : List.unmodifiable(rows);
  }
}
