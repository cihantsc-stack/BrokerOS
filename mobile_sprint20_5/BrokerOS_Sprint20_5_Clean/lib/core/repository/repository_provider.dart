import 'institution_repository.dart';
import 'market_repository.dart';
import 'mock_institution_repository.dart';
import 'mock_market_repository.dart';
import 'mock_news_repository.dart';
import 'news_repository.dart';

class RepositoryProvider {
  RepositoryProvider._();

  static final MarketRepository market = MockMarketRepository();

  static final InstitutionRepository institutions =
      MockInstitutionRepository();

  static final NewsRepository news = MockNewsRepository();
}