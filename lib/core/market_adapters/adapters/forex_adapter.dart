import '../contracts/market_adapter.dart';
import '../models/market_asset_type.dart';
import '../models/normalized_market_quote.dart';

class ForexAdapter implements MarketAdapter {
  @override
  MarketAssetType get assetType => MarketAssetType.forex;

  @override
  String get adapterName => 'Döviz Adapter V1';

  @override
  Future<NormalizedMarketQuote> fetch(String symbol) async {
    await Future<void>.delayed(const Duration(milliseconds: 130));

    return NormalizedMarketQuote(
      symbol: 'USDTRY',
      displayName: 'Dolar / TL',
      assetType: assetType,
      price: 44.82,
      changePercent: -0.12,
      volume: 0,
      currency: 'TRY',
      source: adapterName,
      timestamp: DateTime.now(),
      delayed: true,
    );
  }
}
