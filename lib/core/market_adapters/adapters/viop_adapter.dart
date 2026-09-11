import '../contracts/market_adapter.dart';
import '../models/market_asset_type.dart';
import '../models/normalized_market_quote.dart';

class ViopAdapter implements MarketAdapter {
  @override
  MarketAssetType get assetType => MarketAssetType.viop;

  @override
  String get adapterName => 'VİOP Adapter V1';

  @override
  Future<NormalizedMarketQuote> fetch(String symbol) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    return NormalizedMarketQuote(
      symbol: 'XU030',
      displayName: 'VİOP 30 Yakın Vade',
      assetType: assetType,
      price: 13245.50,
      changePercent: 0.84,
      volume: 1845000000,
      currency: 'TRY',
      source: adapterName,
      timestamp: DateTime.now(),
      delayed: true,
    );
  }
}
