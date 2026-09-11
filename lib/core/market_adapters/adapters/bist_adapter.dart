import '../contracts/market_adapter.dart';
import '../models/market_asset_type.dart';
import '../models/normalized_market_quote.dart';

class BistAdapter implements MarketAdapter {
  @override
  MarketAssetType get assetType => MarketAssetType.bist;

  @override
  String get adapterName => 'BIST Adapter V1';

  @override
  Future<NormalizedMarketQuote> fetch(String symbol) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));

    final int seed = symbol.codeUnits.fold<int>(
      0,
      (int total, int item) => total + item,
    );

    return NormalizedMarketQuote(
      symbol: symbol,
      displayName: '$symbol Hissesi',
      assetType: assetType,
      price: 90 + (seed % 240).toDouble(),
      changePercent: ((seed % 43) - 17) / 10,
      volume: 300000000 + seed * 1250000,
      currency: 'TRY',
      source: adapterName,
      timestamp: DateTime.now(),
      delayed: true,
    );
  }
}
