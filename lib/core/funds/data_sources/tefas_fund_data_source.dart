import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/fund_history_result.dart';
import '../models/fund_price_point.dart';

class TefasFundDataSource {
  static const String _gatewayHost = 'croc-fund-gateway.crocai.workers.dev';

  final http.Client _client;

  TefasFundDataSource({http.Client? client})
    : _client = client ?? http.Client();

  Future<FundHistoryResult> fetchHistory(
    String rawFundCode, {
    int periodMonths = 12,
  }) async {
    final fundCode = _normalizeFundCode(rawFundCode);
    final safePeriod = periodMonths.clamp(1, 60);

    if (fundCode.isEmpty) {
      return _unavailable('', safePeriod, 'GECERLI FON KODU GEREKLI');
    }

    final uri = Uri.https(_gatewayHost, '/', <String, String>{
      'action': 'history',
      'fund': fundCode,
      'period': safePeriod.toString(),
    });

    try {
      final response = await _client
          .get(
            uri,
            headers: const <String, String>{'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        return _unavailable(
          fundCode,
          safePeriod,
          'Fund Gateway HTTP ${response.statusCode}',
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return _unavailable(
          fundCode,
          safePeriod,
          'Fund Gateway yaniti gecersiz.',
        );
      }

      final bool available = decoded['available'] == true;

      if (!available) {
        return _unavailable(
          fundCode,
          safePeriod,
          decoded['status']?.toString() ?? 'VERI BEKLENIYOR',
        );
      }

      final rawPrices = decoded['prices'];

      if (rawPrices is! List) {
        return _unavailable(
          fundCode,
          safePeriod,
          'Fon fiyat serisi bulunamadi.',
        );
      }

      final prices = <FundPricePoint>[];

      for (final dynamic item in rawPrices) {
        if (item is! Map) {
          continue;
        }

        try {
          prices.add(FundPricePoint.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {
          // Tek bozuk kayit tum gercek seriyi dusurmesin.
        }
      }

      prices.sort((a, b) => a.date.compareTo(b.date));

      if (prices.isEmpty) {
        return _unavailable(
          fundCode,
          safePeriod,
          'GECERLI FON FIYAT VERISI YOK',
        );
      }

      final provider = decoded['provider']?.toString().trim().isNotEmpty == true
          ? decoded['provider'].toString().trim()
          : 'TEFAS';

      final fundName = decoded['fundName']?.toString().trim().isNotEmpty == true
          ? decoded['fundName'].toString().trim()
          : null;

      final updatedAt =
          DateTime.tryParse(decoded['updatedAt']?.toString() ?? '') ??
          DateTime.now();

      return FundHistoryResult(
        fundCode: fundCode,
        fundName: fundName,
        periodMonths: safePeriod,
        prices: List<FundPricePoint>.unmodifiable(prices),
        available: true,
        provider: provider,
        status: 'GERCEK TEFAS FIYAT SERISI ALINDI',
        updatedAt: updatedAt,
      );
    } catch (error) {
      return _unavailable(fundCode, safePeriod, 'Fon verisi alinamadi: $error');
    }
  }

  static String _normalizeFundCode(String value) {
    final code = value.trim().toUpperCase();

    if (!RegExp(r'^[A-Z0-9]{2,10}$').hasMatch(code)) {
      return '';
    }

    return code;
  }

  static FundHistoryResult _unavailable(
    String fundCode,
    int periodMonths,
    String status,
  ) {
    return FundHistoryResult(
      fundCode: fundCode,
      fundName: null,
      periodMonths: periodMonths,
      prices: const <FundPricePoint>[],
      available: false,
      provider: 'CROC FUND GATEWAY / TEFAS',
      status: status,
      updatedAt: DateTime.now(),
    );
  }
}
