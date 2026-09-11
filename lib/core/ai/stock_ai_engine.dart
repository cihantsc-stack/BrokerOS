import '../models/stock_analysis.dart';

class StockAiEngine {
  static StockAnalysis analyze(String symbol) {
    return StockAnalysis(
      symbol: symbol,

      company: "ASELSAN",

      aiScore: 94,

      decision: "GÜÇLÜ AL",

      entry: 148.20,

      target1: 153.80,

      target2: 159.40,

      stop: 145.50,

      confidence: 92,

      risk: "Orta",

      reasons: const [
        "Smart Money alımda",

        "RSI güçlü",

        "MACD AL verdi",

        "EMA20 yukarı kesti",

        "Kurumsal para girişi",

        "Yabancı takası artıyor",

        "Savunma sektörü lider",
      ],
    );
  }
}
