import '../cache/disk_cache.dart';
import '../cache/memory_cache.dart';
import '../logger/app_logger.dart';
import '../network/network_monitor.dart';
import '../retry/retry_policy.dart';
import '../sync/sync_engine.dart';
import '../sync/sync_job.dart';
import 'market_repository_v2.dart';
import 'twelve_data_market_data_source.dart';

class LiveDataFoundation {
  LiveDataFoundation._();

  static final LiveDataFoundation instance = LiveDataFoundation._();

  late final MarketRepositoryV2 marketRepository = MarketRepositoryV2(
    remoteSource: TwelveDataMarketDataSource(),
    cache: MemoryCache.instance,
    networkMonitor: NetworkMonitor.instance,
    retryPolicy: const RetryPolicy(),
  );

  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    SyncEngine.instance.register(
      SyncJob(
        id: 'foundation-health',
        title: 'Veri altyapısı sağlık kontrolü',
        action: () async {
          await NetworkMonitor.instance.check();
          await DiskCache.instance.write(
            'last_health_check',
            DateTime.now().toIso8601String(),
          );
        },
      ),
    );

    await SyncEngine.instance.run('foundation-health');

    AppLogger.instance.info('Live Data Foundation başlatıldı.');

    _initialized = true;
  }
}
