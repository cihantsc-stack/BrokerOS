import 'data_source_status.dart';
import 'market_gateway.dart';
import 'mock_market_gateway.dart';

class MarketGatewayManager {
  MarketGatewayManager._();

  static final MarketGatewayManager instance = MarketGatewayManager._();

  MarketGateway _gateway = const MockMarketGateway();

  void useGateway(MarketGateway gateway) {
    _gateway = gateway;
  }

  Future<List<DataSourceStatus>> checkSources() {
    return _gateway.checkSources();
  }
}
