import '../adapters/bist_adapter.dart';
import '../adapters/crypto_adapter.dart';
import '../adapters/forex_adapter.dart';
import '../adapters/gold_adapter.dart';
import '../adapters/tefas_adapter.dart';
import '../adapters/viop_adapter.dart';
import '../contracts/market_adapter.dart';
import '../models/market_asset_type.dart';

class MarketAdapterRegistry {
  MarketAdapterRegistry._();

  static final MarketAdapterRegistry instance = MarketAdapterRegistry._();

  final Map<MarketAssetType, MarketAdapter> _adapters =
      <MarketAssetType, MarketAdapter>{
        MarketAssetType.bist: BistAdapter(),
        MarketAssetType.viop: ViopAdapter(),
        MarketAssetType.forex: ForexAdapter(),
        MarketAssetType.gold: GoldAdapter(),
        MarketAssetType.crypto: CryptoAdapter(),
        MarketAssetType.tefas: TefasAdapter(),
      };

  List<MarketAdapter> get adapters =>
      List<MarketAdapter>.unmodifiable(_adapters.values);

  MarketAdapter adapterFor(MarketAssetType type) {
    final MarketAdapter? adapter = _adapters[type];

    if (adapter == null) {
      throw StateError('${type.name} için adapter bulunamadı.');
    }

    return adapter;
  }
}
