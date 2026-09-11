import '../database/bist100_master_database.dart';
import '../engine/market_breadth_engine.dart';
import '../engine/sector_strength_engine.dart';
import '../models/bist_stock.dart';
import '../models/bist_stock_tick.dart';
import '../models/market_breadth.dart';
import '../models/sector_strength.dart';

class Bist100IntelligenceResult {
  final MarketBreadth breadth;
  final List<SectorStrength> sectors;
  final List<BistStockTick> strongestStocks;
  final List<BistStockTick> weakestStocks;

  const Bist100IntelligenceResult({
    required this.breadth,
    required this.sectors,
    required this.strongestStocks,
    required this.weakestStocks,
  });
}

class Bist100IntelligenceService {
  final MarketBreadthEngine breadthEngine;
  final SectorStrengthEngine sectorEngine;

  const Bist100IntelligenceService({
    this.breadthEngine = const MarketBreadthEngine(),
    this.sectorEngine = const SectorStrengthEngine(),
  });

  Bist100IntelligenceResult analyze(List<BistStockTick> ticks) {
    final List<BistStockTick> sorted = List<BistStockTick>.from(ticks)
      ..sort(
        (BistStockTick a, BistStockTick b) =>
            b.changePercent.compareTo(a.changePercent),
      );

    return Bist100IntelligenceResult(
      breadth: breadthEngine.calculate(ticks),
      sectors: sectorEngine.calculate(ticks),
      strongestStocks: sorted.take(5).toList(growable: false),
      weakestStocks: sorted.reversed.take(5).toList(growable: false),
    );
  }

  List<BistStock> get universe => Bist100MasterDatabase.stocks;
}
