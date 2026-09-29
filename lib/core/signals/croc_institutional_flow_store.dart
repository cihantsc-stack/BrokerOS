import 'croc_institutional_strength_engine.dart';

/// Session-only verified participant data, indexed by BIST ticker.
/// Only trusted adapters should call [accept]. A report is not proof
/// that its participants are institutions rather than brokerage accounts.
class CrocInstitutionalFlowStore {
  CrocInstitutionalFlowStore._();

  static final CrocInstitutionalFlowStore instance =
      CrocInstitutionalFlowStore._();

  final Map<String, CrocParticipantFlowReport> _reports = {};

  bool accept({
    required String symbol,
    required CrocInstitutionalSource source,
    required List<CrocParticipantFlow> rows,
    DateTime? asOf,
  }) {
    final normalized = symbol.trim().toUpperCase();
    if (!RegExp(r'^[A-Z0-9]{3,8}$').hasMatch(normalized)) return false;
    final report = const CrocParticipantFlowAggregator().aggregate(
      source: source,
      rows: rows,
      asOf: asOf ?? DateTime.now(),
    );
    if (report == null) return false;
    final previous = _reports[normalized];
    if (previous != null &&
        !source.observedAt.isAfter(previous.source.observedAt)) {
      return false;
    }
    _reports[normalized] = report;
    return true;
  }

  CrocParticipantFlowReport? report(String symbol, {DateTime? asOf}) {
    final result = _reports[symbol.trim().toUpperCase()];
    if (result == null) return null;
    final now = asOf ?? DateTime.now();
    if (result.source.observedAt.isAfter(now) ||
        now.difference(result.source.observedAt) > const Duration(days: 1)) {
      return null;
    }
    return result;
  }

  void clear() => _reports.clear();
}
