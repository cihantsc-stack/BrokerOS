import '../contracts/market_adapter.dart';
import '../models/market_asset_type.dart';
import '../models/normalized_market_quote.dart';

class TefasAdapter implements MarketAdapter {
  @override
  MarketAssetType get assetType => MarketAssetType.tefas;

  @override
  String get adapterName => 'TEFAS Adapter V1';

  @override
  Future<NormalizedMarketQuote> fetch(String symbol) async {
    await Future<void>.delayed(const Duration(milliseconds: 170));

    return NormalizedMarketQuote(
      symbol: 'MAC',
      displayName: 'Hisse Senedi Fonu',
      assetType: assetType,
      price: 12.6842,
      changePercent: 0.42,
      volume: 965000000,
      currency: 'TRY',
      source: adapterName,
      timestamp: DateTime.now(),
      delayed: true,
    );
  }
}
