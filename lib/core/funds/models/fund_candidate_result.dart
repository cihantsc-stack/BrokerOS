import '../data_sources/tefas_fund_data_source.dart';
import 'fund_intelligence_result.dart';
import 'fund_metrics_result.dart';

class FundCandidateResult {
  final FundSearchItem fund;
  final FundMetricsResult metrics;
  final FundIntelligenceResult intelligence;
  final int suitabilityScore;
  final String suitabilityLabel;
  final List<String> reasons;

  const FundCandidateResult({
    required this.fund,
    required this.metrics,
    required this.intelligence,
    required this.suitabilityScore,
    required this.suitabilityLabel,
    required this.reasons,
  });
}
