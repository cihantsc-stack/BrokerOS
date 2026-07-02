import '../models/market_snapshot.dart';

class BrokerVisionService {
  static String generate(MarketSnapshot data) {
    final buffer = StringBuffer();

    if (data.moneyFlow > 0) {
      buffer.write(
        "Bugün piyasaya yeni para girişi pozitif görünüyor. ",
      );
    } else {
      buffer.write(
        "Bugün piyasada para çıkışı dikkat çekiyor. ",
      );
    }

    if (data.smartMoney > 0) {
      buffer.write(
        "Smart Money tarafında alım iştahı korunuyor. ",
      );
    }

    if (data.newsScore > 70) {
      buffer.write(
        "Haber akışı genel olarak pozitif. ",
      );
    }

    if (data.volatility > 60) {
      buffer.write(
        "Ancak volatilite yüksek olduğu için temkinli ilerlemek daha doğru olabilir.",
      );
    } else {
      buffer.write(
        "Risk seviyesi kontrol edilebilir görünüyor.",
      );
    }

    return buffer.toString();
  }
}