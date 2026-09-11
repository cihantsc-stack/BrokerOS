import '../../../core/data_foundation/market/market_tick.dart';

class DataTerminalQuote {
  final String code;
  final String company;
  final MarketTick tick;

  const DataTerminalQuote({
    required this.code,
    required this.company,
    required this.tick,
  });

  double get price => tick.price;
  double get changePercent => tick.changePercent;
  double get volume => tick.volume;
  DateTime get timestamp => tick.timestamp;
}
