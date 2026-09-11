import '../bist/database/bist100_master_database.dart';
import '../models/stock_analysis.dart';

class MarketScanner {
  const MarketScanner._();

  static List<StockAnalysis> scan() {
    return Bist100MasterDatabase.stocks
        .map(
          (stock) => StockAnalysis(
            symbol: stock.code,
            company: stock.name,
            aiScore: 0,
            decision: 'VERİ BEKLENİYOR',
            entry: 0,
            target1: 0,
            target2: 0,
            stop: 0,
            confidence: 0,
            risk: 'VERİ BEKLENİYOR',
            reasons: const <String>['Canlı piyasa analizi henüz yüklenmedi.'],
          ),
        )
        .toList(growable: false);
  }
}
