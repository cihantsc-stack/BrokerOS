import '../signals/croc_institutional_flow_store.dart';
import '../signals/croc_institutional_strength_engine.dart';
import 'croc_akd_decision_bridge.dart';
import 'croc_akd_engine.dart';
import 'croc_matriks_akd_parser.dart';

/// Imports a Matriks-style AKD table into the session verified-flow store.
///
/// Provenance is explicit: callers must provide an authenticated source.
/// Parsing and AKD integrity are checked before the store is touched.
class CrocMatriksAkdAdapter {
  const CrocMatriksAkdAdapter({
    this.parser = const CrocMatriksAkdParser(),
    this.engine = const CrocAkdEngine(),
    this.bridge = const CrocAkdDecisionBridge(),
  });

  final CrocMatriksAkdParser parser;
  final CrocAkdEngine engine;
  final CrocAkdDecisionBridge bridge;

  bool import({
    required String symbol,
    required List<List<Object?>> table,
    required CrocInstitutionalSource source,
    DateTime? asOf,
    CrocInstitutionalFlowStore? store,
  }) {
    final rows = parser.parseRows(table);
    if (rows.isEmpty) return false;

    final result = engine.analyze(rows);
    final evidence = bridge.inspect(result);
    if (!evidence.isEligible) return false;

    final participantRows = rows
        .map(
          (row) => CrocParticipantFlow(
            participant: row.institution,
            buyLots: row.buyLots,
            sellLots: row.sellLots,
          ),
        )
        .toList(growable: false);

    return (store ?? CrocInstitutionalFlowStore.instance).accept(
      symbol: symbol,
      source: source,
      rows: participantRows,
      asOf: asOf,
    );
  }
}
