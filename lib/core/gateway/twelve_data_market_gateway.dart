import '../data_foundation/market/twelve_data_market_data_source.dart';
import 'data_source_status.dart';
import 'market_gateway.dart';

class TwelveDataMarketGateway implements MarketGateway {
  TwelveDataMarketGateway({TwelveDataMarketDataSource? marketDataSource})
    : _marketDataSource = marketDataSource ?? TwelveDataMarketDataSource();

  final TwelveDataMarketDataSource _marketDataSource;

  @override
  Future<List<DataSourceStatus>> checkSources() async {
    final DateTime startedAt = DateTime.now();

    DataSourceStatus marketStatus;

    try {
      final tick = await _marketDataSource.fetchQuote('USDTRY');
      final Duration responseTime = DateTime.now().difference(startedAt);

      final bool isDelayed = responseTime > const Duration(seconds: 5);

      marketStatus = DataSourceStatus(
        id: 'market',
        name: 'Twelve Data Piyasa Verisi',
        description:
            '${tick.symbol}: ${tick.price.toStringAsFixed(4)} • '
            '${tick.source}',
        state: isDelayed ? DataSourceState.delayed : DataSourceState.connected,
        delay: responseTime,
        checkedAt: DateTime.now(),
      );
    } catch (error) {
      marketStatus = DataSourceStatus(
        id: 'market',
        name: 'Twelve Data Piyasa Verisi',
        description: _cleanError(error),
        state: DataSourceState.unavailable,
        checkedAt: DateTime.now(),
      );
    }

    return <DataSourceStatus>[
      marketStatus,
      DataSourceStatus(
        id: 'news',
        name: 'Haber Akışı',
        description: 'Finansal haber sağlayıcısı bağlantısı hazırlanıyor.',
        state: DataSourceState.planned,
        checkedAt: DateTime.now(),
      ),
      DataSourceStatus(
        id: 'kap',
        name: 'KAP Bildirimleri',
        description: 'Şirket açıklamaları ve önemli gelişmeler.',
        state: DataSourceState.planned,
        checkedAt: DateTime.now(),
      ),
      DataSourceStatus(
        id: 'macro',
        name: 'Makro Veri',
        description: 'TCMB, faiz, kur ve risk göstergeleri.',
        state: DataSourceState.planned,
        checkedAt: DateTime.now(),
      ),
    ];
  }

  String _cleanError(Object error) {
    final String message = error.toString().trim();

    if (message.length <= 150) {
      return message;
    }

    return '${message.substring(0, 147)}...';
  }
}
