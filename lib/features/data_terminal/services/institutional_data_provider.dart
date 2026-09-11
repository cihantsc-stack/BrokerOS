import '../models/institutional_models.dart';

abstract class InstitutionalDataProvider {
  String get providerName;

  Future<InstitutionalDataBundle> fetch(String symbol);
}
