import '../models/institution_flow.dart';
import 'institution_repository.dart';

class MockInstitutionRepository implements InstitutionRepository {
  @override
  List<InstitutionFlow> getTodayFlows() {
    return const <InstitutionFlow>[];
  }
}
