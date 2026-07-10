import '../models/market_news.dart';

abstract class NewsRepository {
  List<MarketNews> getLatestNews();
}