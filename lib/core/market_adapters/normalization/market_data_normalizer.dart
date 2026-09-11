import '../models/normalized_market_quote.dart';

class MarketDataNormalizer {
  const MarketDataNormalizer();

  NormalizedMarketQuote normalize(NormalizedMarketQuote quote) {
    return quote.copyWith(
      displayName: quote.displayName.trim(),
      price: double.parse(quote.price.toStringAsFixed(4)),
      changePercent: double.parse(quote.changePercent.toStringAsFixed(2)),
      volume: quote.volume < 0 ? 0 : quote.volume,
      currency: quote.currency.toUpperCase(),
      source: quote.source.trim(),
    );
  }
}
