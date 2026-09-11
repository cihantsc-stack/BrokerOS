import '../models/market_asset_type.dart';
import '../models/normalized_market_quote.dart';

abstract interface class MarketAdapter {
  MarketAssetType get assetType;

  String get adapterName;

  Future<NormalizedMarketQuote> fetch(String symbol);
}
