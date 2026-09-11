import 'network/connection_status.dart';

class DataFoundationStatus {
  final ConnectionStatus connectionStatus;
  final int memoryCacheItems;
  final int diskCacheItems;
  final int syncJobCount;
  final bool initialized;
  final DateTime checkedAt;

  const DataFoundationStatus({
    required this.connectionStatus,
    required this.memoryCacheItems,
    required this.diskCacheItems,
    required this.syncJobCount,
    required this.initialized,
    required this.checkedAt,
  });
}
