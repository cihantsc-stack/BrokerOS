import '../models/institutional_models.dart';
import 'institutional_data_provider.dart';

class UnavailableInstitutionalDataProvider
    implements InstitutionalDataProvider {
  const UnavailableInstitutionalDataProvider();

  @override
  String get providerName => 'Kurumsal veri sağlayıcısı';

  @override
  Future<InstitutionalDataBundle> fetch(String symbol) async {
    return InstitutionalDataBundle(
      symbol: symbol,
      providerName: providerName,
      providerConnected: false,
      statusMessage:
          'AKD, kurum bazlı işlemler, takas ve derinlik için lisanslı veri sağlayıcısı henüz bağlı değil.',
    );
  }
}
