import '../../bist/database/bist100_master_database.dart';

class BistSymbolCatalog {
  const BistSymbolCatalog._();

  static final Map<String, String> companies = <String, String>{
    for (final stock in Bist100MasterDatabase.stocks) stock.code: stock.name,
  };

  static String companyOf(String symbol) {
    return companies[symbol.trim().toUpperCase()] ?? '$symbol Hissesi';
  }

  static List<String> search(String query) {
    final String normalized = _normalize(query);

    if (normalized.isEmpty) {
      return companies.keys.toList(growable: false);
    }

    return companies.entries
        .where(
          (MapEntry<String, String> entry) =>
              _normalize(entry.key).contains(normalized) ||
              _normalize(entry.value).contains(normalized),
        )
        .map((MapEntry<String, String> entry) => entry.key)
        .toList(growable: false);
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toUpperCase()
        .replaceAll('İ', 'I')
        .replaceAll('Ş', 'S')
        .replaceAll('Ğ', 'G')
        .replaceAll('Ü', 'U')
        .replaceAll('Ö', 'O')
        .replaceAll('Ç', 'C');
  }
}
