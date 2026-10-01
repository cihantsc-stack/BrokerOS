import '../akd/croc_akd_decision_bridge.dart';
import '../akd/croc_akd_engine.dart';
import '../akd/croc_akd_models.dart';
import 'croc_institutional_strength_engine.dart';

/// Session-only verified participant data, indexed by BIST ticker.
/// Only trusted adapters should call [accept]. A report is not proof
/// that its participants are institutions rather than brokerage accounts.
///
/// Before a report reaches the UI, the same AKD integrity guard used by the
/// Matriks analysis path rejects incomplete net books and one-sided/distorted
/// flow. This prevents a verified provider label from bypassing AKD quality.
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

    final akdRows = report.participants
        .map(
          (row) => CrocAkdBrokerRow(
            institution: row.participant,
            buyLots: row.buyLots,
            buyAverage: 0,
            sellLots: row.sellLots,
            sellAverage: 0,
            totalLots: row.buyLots + row.sellLots,
            sharePercent: 0,
            netLots: row.netLots,
            cost: 0,
          ),
        )
        .toList(growable: false);

    final akdResult = const CrocAkdEngine().analyze(akdRows);
    final akdEvidence = const CrocAkdDecisionBridge().inspect(akdResult);
    if (!akdEvidence.isEligible) return false;

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

  /// Names and signed net lots from a licensed, verified report only.
  /// Returns no rows when the provider snapshot is missing or expired.
  List<CrocParticipantFlow> participants(
    String symbol, {
    DateTime? asOf,
  }) {
    final verified = report(symbol, asOf: asOf);
    if (verified == null) return const [];
    return verified.participants;
  }

  void clear() => _reports.clear();
}
