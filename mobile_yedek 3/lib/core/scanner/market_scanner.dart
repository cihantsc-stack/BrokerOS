import '../models/stock_analysis.dart';

class MarketScanner {
  static List<StockAnalysis> scan() {
    return const [
      StockAnalysis(
        symbol: "ASELS",
        company: "ASELSAN",
        aiScore: 94,
        decision: "GÜÇLÜ AL",
        entry: 148.20,
        target1: 153.80,
        target2: 159.40,
        stop: 145.40,
        confidence: 92,
        risk: "Orta",
        reasons: [
          "Smart Money",
          "RSI",
          "MACD",
        ],
      ),
      StockAnalysis(
        symbol: "THYAO",
        company: "Türk Hava Yolları",
        aiScore: 89,
        decision: "AL",
        entry: 331,
        target1: 340,
        target2: 352,
        stop: 323,
        confidence: 88,
        risk: "Orta",
        reasons: [
          "EMA20",
          "Kurumsal Para",
        ],
      ),
      StockAnalysis(
        symbol: "GARAN",
        company: "Garanti BBVA",
        aiScore: 84,
        decision: "İZLE",
        entry: 132,
        target1: 138,
        target2: 144,
        stop: 128,
        confidence: 80,
        risk: "Düşük",
        reasons: [
          "Fon Girişi",
        ],
      ),
    ];
  }
}