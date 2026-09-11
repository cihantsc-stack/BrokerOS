import '../contracts/market_adapter.dart';
import '../models/market_asset_type.dart';
import '../models/normalized_market_quote.dart';

class CryptoAdapter implements MarketAdapter {
  @override
  MarketAssetType get assetType => MarketAssetType.crypto;

  @override
  String get adapterName => 'Kripto Adapter V1';

  @override
  Future<NormalizedMarketQuote> fetch(String symbol) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));

    return NormalizedMarketQuote(
      symbol: 'BTCUSDT',
      displayName: 'Bitcoin',
      assetType: assetType,
      price: 118420.0,
      changePercent: 1.26,
      volume: 28400000000,
      currency: 'USD',
      source: adapterName,
      timestamp: DateTime.now(),
      delayed: true,
    );
  }
}
