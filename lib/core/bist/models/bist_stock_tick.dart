import 'bist_stock.dart';

class BistStockTick {
  final BistStock stock;
  final double price;
  final double changePercent;
  final double volume;

  const BistStockTick({
    required this.stock,
    required this.price,
    required this.changePercent,
    required this.volume,
  });

  bool get isRising => changePercent > 0;
  bool get isFalling => changePercent < 0;
  bool get isFlat => changePercent == 0;
}
