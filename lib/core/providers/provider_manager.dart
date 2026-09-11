import 'fund_provider.dart';
import 'institution_provider.dart';
import 'market_provider.dart';
import 'news_provider.dart';
import 'technical_provider.dart';

class ProviderBundle {
  final MarketSnapshotData market;
  final InstitutionFlowData institution;
  final NewsSignalData news;
  final FundFlowData fund;
  final TechnicalSignalData technical;

  const ProviderBundle({
    required this.market,
    required this.institution,
    required this.news,
    required this.fund,
    required this.technical,
  });

  bool get hasMarket => market.available;
  bool get hasTechnical => technical.available;
  bool get hasInstitution => institution.available;
  bool get hasNews => news.available;
  bool get hasFund => fund.available;

  int get activeProviderCount => <bool>[
    hasMarket,
    hasTechnical,
    hasInstitution,
    hasNews,
    hasFund,
  ].where((value) => value).length;
}

class ProviderManager {
  ProviderManager._({
    required this.market,
    required this.institution,
    required this.news,
    required this.fund,
    required this.technical,
  });

  static final ProviderManager instance = ProviderManager._(
    market: CrocLiveMarketProvider(),
    institution: const UnavailableInstitutionProvider(),
    news: CrocLiveNewsProvider(),
    fund: const UnavailableFundProvider(),
    technical: CrocLiveTechnicalProvider(),
  );

  final MarketProvider market;
  final InstitutionProvider institution;
  final NewsProvider news;
  final FundProvider fund;
  final TechnicalProvider technical;

  Future<ProviderBundle> load(String symbol) async {
    final cleanSymbol = symbol.trim().toUpperCase().replaceAll('.IS', '');

    final results = await Future.wait<dynamic>([
      market.fetch(cleanSymbol),
      technical.fetch(cleanSymbol),
      institution.fetch(cleanSymbol),
      news.fetch(cleanSymbol),
      fund.fetch(cleanSymbol),
    ]);

    return ProviderBundle(
      market: results[0] as MarketSnapshotData,
      technical: results[1] as TechnicalSignalData,
      institution: results[2] as InstitutionFlowData,
      news: results[3] as NewsSignalData,
      fund: results[4] as FundFlowData,
    );
  }

  void clearCache() {
    // V22: eski mock MemoryCache kaldirildi.
    // Canli provider cache mimarisi sonraki surumde merkezi hale getirilecek.
  }
}
