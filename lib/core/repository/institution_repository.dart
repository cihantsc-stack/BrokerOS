import '../models/institution_flow.dart';

abstract class InstitutionRepository {
  List<InstitutionFlow> getTodayFlows();
}
