import 'cache/disk_cache.dart';
import 'cache/memory_cache.dart';
import 'data_foundation_status.dart';
import 'market/live_data_foundation.dart';
import 'network/network_monitor.dart';
import 'sync/sync_engine.dart';

class DataFoundationService {
  DataFoundationService._();

  static final DataFoundationService instance = DataFoundationService._();

  Future<DataFoundationStatus> inspect() async {
    await LiveDataFoundation.instance.initialize();

    return DataFoundationStatus(
      connectionStatus: NetworkMonitor.instance.currentStatus,
      memoryCacheItems: MemoryCache.instance.itemCount,
      diskCacheItems: DiskCache.instance.itemCount,
      syncJobCount: SyncEngine.instance.jobs.length,
      initialized: LiveDataFoundation.instance.isInitialized,
      checkedAt: DateTime.now(),
    );
  }
}
