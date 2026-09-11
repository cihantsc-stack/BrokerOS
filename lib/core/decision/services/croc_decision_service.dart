import '../../models/stock_analysis.dart';
import '../engines/croc_decision_engine.dart';
import '../models/croc_decision_result.dart';

class CrocDecisionService {
  CrocDecisionService._();

  static final CrocDecisionService instance = CrocDecisionService._();

  final CrocDecisionEngine _engine = const CrocDecisionEngine();

  CrocDecisionResult analyze(StockAnalysis stock) {
    return _engine.analyze(stock);
  }
}
