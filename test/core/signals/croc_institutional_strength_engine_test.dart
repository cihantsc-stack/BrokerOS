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
      participantDataVerified: true,
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
      participantDataVerified: true,
    );
    expect(result.evidence, CrocInstitutionalEvidence.unavailable);
  });
}
