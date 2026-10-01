import 'package:flutter/services.dart';

import 'croc_live_akd_snapshot.dart';

class CrocWindowsMatriksAkdBridge {
  const CrocWindowsMatriksAkdBridge();

  static const MethodChannel _channel = MethodChannel(
    'croc/windows_matriks_akd',
  );

  Future<CrocLiveAkdSnapshot?> readSnapshot() async {
    final payload = await _channel.invokeMapMethod<String, dynamic>(
      'readSnapshot',
    );
    if (payload == null) return null;

    final symbol = payload['symbol']?.toString() ?? '';
    final buyers = _rows(payload['buyers']);
    final sellers = _rows(payload['sellers']);

    return const CrocLiveAkdSnapshotParser().parse(
      symbol: symbol,
      buyerRanking: buyers,
      sellerRanking: sellers,
    );
  }

  List<CrocLiveAkdNetRow> _rows(Object? raw) {
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((row) {
          final institution = row['institution']?.toString() ?? '';
          final value = row['netLots'];
          final netLots = value is num
              ? value.toDouble()
              : double.tryParse(value?.toString() ?? '');
          if (institution.trim().isEmpty || netLots == null) return null;
          return CrocLiveAkdNetRow(
            institution: institution,
            netLots: netLots,
          );
        })
        .whereType<CrocLiveAkdNetRow>()
        .toList(growable: false);
  }
}
