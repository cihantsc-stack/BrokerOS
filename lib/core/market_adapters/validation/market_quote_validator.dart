import '../models/normalized_market_quote.dart';

class MarketQuoteValidator {
  const MarketQuoteValidator();

  bool isValid(NormalizedMarketQuote quote) {
    return quote.symbol.trim().isNotEmpty &&
        quote.price.isFinite &&
        quote.price >= 0 &&
        quote.changePercent.isFinite &&
        quote.volume.isFinite &&
        quote.timestamp.isBefore(
          DateTime.now().add(const Duration(minutes: 1)),
        );
  }

  List<String> validate(NormalizedMarketQuote quote) {
    final List<String> errors = <String>[];

    if (quote.symbol.trim().isEmpty) {
      errors.add('Sembol boş olamaz.');
    }

    if (!quote.price.isFinite || quote.price < 0) {
      errors.add('Fiyat geçersiz.');
    }

    if (!quote.changePercent.isFinite) {
      errors.add('Değişim oranı geçersiz.');
    }

    if (!quote.volume.isFinite) {
      errors.add('Hacim geçersiz.');
    }

    return errors;
  }
}
