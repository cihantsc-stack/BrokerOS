import '../cache/memory_cache.dart';
import '../network/connection_status.dart';
import '../network/network_monitor.dart';
import '../repository/base_repository.dart';
import '../result/app_failure.dart';
import '../result/app_result.dart';
import '../retry/retry_policy.dart';
import 'market_data_source.dart';
import 'market_tick.dart';

class MarketRepositoryV2 extends BaseRepository {
  final MarketDataSource remoteSource;
  final MemoryCache cache;
  final NetworkMonitor networkMonitor;
  final RetryPolicy retryPolicy;

  MarketRepositoryV2({
    required this.remoteSource,
    required this.cache,
    required this.networkMonitor,
    required this.retryPolicy,
  });

  Future<AppResult<MarketTick>> getQuote(
    String symbol, {
    bool forceRefresh = false,
  }) async {
    final String key = 'market_quote_$symbol';

    if (!forceRefresh) {
      final MarketTick? cached = cache.get<MarketTick>(key);

      if (cached != null) {
        return AppSuccess<MarketTick>(cached);
      }
    }

    final ConnectionStatus status = await networkMonitor.check();

    if (status == ConnectionStatus.offline) {
      final MarketTick? cached = cache.get<MarketTick>(key);

      if (cached != null) {
        return AppSuccess<MarketTick>(cached);
      }

      return const AppError<MarketTick>(
        AppFailure(
          code: 'offline_no_cache',
          message: 'Bağlantı yok ve kullanılabilir önbellek bulunamadı.',
        ),
      );
    }

    return guard<MarketTick>(() async {
      final MarketTick tick = await retryPolicy.execute<MarketTick>(
        () => remoteSource.fetchQuote(symbol),
      );

      cache.put<MarketTick>(key, tick, ttl: const Duration(seconds: 30));

      return tick;
    });
  }
}
