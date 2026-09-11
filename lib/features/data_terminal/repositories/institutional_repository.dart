import '../models/institutional_models.dart';
import '../services/institutional_data_provider.dart';
import '../services/unavailable_institutional_data_provider.dart';

class InstitutionalRepository {
  final InstitutionalDataProvider provider;

  InstitutionalRepository({InstitutionalDataProvider? provider})
    : provider = provider ?? const UnavailableInstitutionalDataProvider();

  Future<InstitutionalDataBundle> load(String symbol) {
    return provider.fetch(symbol.trim().toUpperCase());
  }
}
