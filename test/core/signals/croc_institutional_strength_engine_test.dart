import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/signals/croc_institutional_strength_engine.dart';

void main() {
  const engine = CrocInstitutionalStrengthEngine();

  test('technical indicators never impersonate verified institutions', () {
    final result = engine.evaluate(
      cmf: 0.25,
      vwap: 99,
      price: 101,
      volumeRatio: 3,
    );
    expect(result.evidence, CrocInstitutionalEvidence.technicalProxy);
    expect(result.label, 'TEKNİK PARA AKIŞI +');
    expect(result.verifiedNetLots, isNull);
  });

  test('unverified participant values are ignored', () {
    final result = engine.evaluate(
      cmf: null,
      vwap: null,
      price: null,
      volumeRatio: null,
      verifiedBuyLots: 1000,
      verifiedSellLots: 100,
    );
    expect(result.evidence, CrocInstitutionalEvidence.unavailable);
    expect(result.verifiedNetLots, isNull);
  });

  test('verified participant net flow is calculated from real supplied lots', () {
    final result = engine.evaluate(
      cmf: null,
      vwap: null,
      price: null,
      volumeRatio: null,
      verifiedBuyLots: 1000,
      verifiedSellLots: 250,
      participantSource: CrocInstitutionalSource(
        provider: 'TEST_FEED',
        observedAt: DateTime.utc(2026, 9, 28, 12),
        authenticated: true,
      ),
      asOf: DateTime.utc(2026, 9, 28, 13),
    );
    expect(result.evidence, CrocInstitutionalEvidence.verifiedParticipantFlow);
    expect(result.verifiedNetLots, 750);
  });

  test('invalid participant lots cannot create verified claims', () {
    final result = engine.evaluate(
      cmf: null,
      vwap: null,
      price: null,
      volumeRatio: null,
      verifiedBuyLots: -10,
      verifiedSellLots: 2,
      participantSource: CrocInstitutionalSource(
        provider: 'TEST_FEED',
        observedAt: DateTime.utc(2026, 9, 28, 12),
        authenticated: true,
      ),
      asOf: DateTime.utc(2026, 9, 28, 13),
    );
    expect(result.evidence, CrocInstitutionalEvidence.unavailable);
  });
  test('stale provider data cannot claim verified institutional flow', () {
    final result = engine.evaluate(
      cmf: 0.1,
      vwap: 99,
      price: 100,
      volumeRatio: 2,
      verifiedBuyLots: 1000,
      verifiedSellLots: 100,
      participantSource: CrocInstitutionalSource(
        provider: 'TEST_FEED',
        observedAt: DateTime.utc(2026, 9, 25, 12),
        authenticated: true,
      ),
      asOf: DateTime.utc(2026, 9, 28, 13),
    );
    expect(result.evidence, CrocInstitutionalEvidence.technicalProxy);
    expect(result.verifiedNetLots, isNull);
  });

  test('unauthenticated provider cannot claim verified flow', () {
    final result = engine.evaluate(
      cmf: null,
      vwap: null,
      price: null,
      volumeRatio: null,
      verifiedBuyLots: 1000,
      verifiedSellLots: 100,
      participantSource: CrocInstitutionalSource(
        provider: 'TEST_FEED',
        observedAt: DateTime.utc(2026, 9, 28, 12),
        authenticated: false,
      ),
      asOf: DateTime.utc(2026, 9, 28, 13),
    );
    expect(result.evidence, CrocInstitutionalEvidence.unavailable);
  });

  test('verified broker rows aggregate and sort by net lots', () {
    final report = const CrocParticipantFlowAggregator().aggregate(
      source: CrocInstitutionalSource(
        provider: 'TEST_FEED',
        observedAt: DateTime.utc(2026, 9, 28, 12),
        authenticated: true,
      ),
      rows: const [
        CrocParticipantFlow(participant: 'A', buyLots: 100, sellLots: 40),
        CrocParticipantFlow(participant: 'B', buyLots: 10, sellLots: 90),
      ],
      asOf: DateTime.utc(2026, 9, 28, 13),
    );
    expect(report, isNotNull);
    expect(report!.netLots, -20);
    expect(report.participants.first.participant, 'A');
    expect(report.participants.last.netLots, -80);
    expect(report.topNetBuyer?.participant, 'A');
    expect(report.topNetBuyer?.netLots, 60);
    expect(report.topNetSeller?.participant, 'B');
    expect(report.topNetSeller?.netLots, -80);
  });

  test('duplicate participant identifiers invalidate a report', () {
    final report = const CrocParticipantFlowAggregator().aggregate(
      source: CrocInstitutionalSource(
        provider: 'TEST_FEED',
        observedAt: DateTime.utc(2026, 9, 28, 12),
        authenticated: true,
      ),
      rows: const [
        CrocParticipantFlow(participant: 'A', buyLots: 100, sellLots: 40),
        CrocParticipantFlow(participant: ' a ', buyLots: 10, sellLots: 90),
      ],
      asOf: DateTime.utc(2026, 9, 28, 13),
    );
    expect(report, isNull);
  });

}
