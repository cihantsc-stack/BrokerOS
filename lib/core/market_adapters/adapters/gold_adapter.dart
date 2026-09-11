import '../contracts/market_adapter.dart';
import '../models/market_asset_type.dart';
import '../models/normalized_market_quote.dart';

class GoldAdapter implements MarketAdapter {
  @override
  MarketAssetType get assetType => MarketAssetType.gold;

  @override
  String get adapterName => 'Altın Adapter V1';

  @override
  Future<NormalizedMarketQuote> fetch(String symbol) async {
    await Future<void>.delayed(const Duration(milliseconds: 140));

    return NormalizedMarketQuote(
      symbol: 'GRAMALTIN',
      displayName: 'Gram Altın',
      assetType: assetType,
      price: 6428.35,
      changePercent: 0.67,
      volume: 0,
      currency: 'TRY',
      source: adapterName,
      timestamp: DateTime.now(),
      delayed: true,
    );
  }
}
