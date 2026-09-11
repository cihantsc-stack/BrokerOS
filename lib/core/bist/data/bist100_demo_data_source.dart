import '../database/bist100_master_database.dart';
import '../models/bist_stock_tick.dart';

class Bist100DemoDataSource {
  const Bist100DemoDataSource();

  List<BistStockTick> load() {
    return List<BistStockTick>.generate(Bist100MasterDatabase.stocks.length, (
      int index,
    ) {
      final stock = Bist100MasterDatabase.stocks[index];
      final int seed = stock.code.codeUnits.fold<int>(
        index + 17,
        (int value, int unit) => (value * 31 + unit) & 0x7fffffff,
      );

      final double price = 12 + ((seed % 76000) / 100);
      final double change = (((seed ~/ 13) % 900) - 400) / 100;
      final double volume = 1000000 + ((seed % 900) * 100000);

      return BistStockTick(
        stock: stock,
        price: price,
        changePercent: change,
        volume: volume,
      );
    }, growable: false);
  }
}
