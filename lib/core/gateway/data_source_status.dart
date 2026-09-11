enum DataSourceState { connected, delayed, planned, unavailable }

extension DataSourceStateLabel on DataSourceState {
  String get label {
    switch (this) {
      case DataSourceState.connected:
        return 'BAĞLI';
      case DataSourceState.delayed:
        return 'GECİKMELİ';
      case DataSourceState.planned:
        return 'PLANLANDI';
      case DataSourceState.unavailable:
        return 'KAPALI';
    }
  }
}

class DataSourceStatus {
  final String id;
  final String name;
  final String description;
  final DataSourceState state;
  final Duration? delay;
  final DateTime checkedAt;

  const DataSourceStatus({
    required this.id,
    required this.name,
    required this.description,
    required this.state,
    required this.checkedAt,
    this.delay,
  });
}
