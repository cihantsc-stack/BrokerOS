import '../models/market_news.dart';
import 'news_repository.dart';

class MockNewsRepository implements NewsRepository {
  @override
  List<MarketNews> getLatestNews() {
    return [
      MarketNews(
        title: 'Savunma sanayi siparişlerinde güçlü görünüm',
        source: 'KAP',
        publishedAt: DateTime(2026, 7, 10, 9, 15),
        sentimentScore: 88,
        impact: 'Pozitif',
        relatedSymbols: const ['ASELS'],
      ),
      MarketNews(
        title: 'Havacılıkta yolcu trafiği beklentilerin üzerinde',
        source: 'Sektör Haberi',
        publishedAt: DateTime(2026, 7, 10, 8, 40),
        sentimentScore: 82,
        impact: 'Pozitif',
        relatedSymbols: const ['THYAO'],
      ),
      MarketNews(
        title: 'Bankacılık sektöründe marj baskısı izleniyor',
        source: 'Piyasa Notu',
        publishedAt: DateTime(2026, 7, 10, 8, 10),
        sentimentScore: 58,
        impact: 'Nötr',
        relatedSymbols: const ['GARAN', 'AKBNK'],
      ),
    ];
  }
}