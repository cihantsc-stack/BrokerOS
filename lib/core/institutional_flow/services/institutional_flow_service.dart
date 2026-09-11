import '../engines/institutional_flow_engine.dart';
import '../models/institutional_flow_snapshot.dart';

class InstitutionalFlowService {
  InstitutionalFlowService._();

  static final InstitutionalFlowService instance = InstitutionalFlowService._();

  Future<InstitutionalFlowSnapshot> load(String symbol) {
    return InstitutionalFlowEngine.instance.analyze(symbol);
  }
}
