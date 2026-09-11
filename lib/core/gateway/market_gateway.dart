import 'data_source_status.dart';

abstract interface class MarketGateway {
  Future<List<DataSourceStatus>> checkSources();
}
