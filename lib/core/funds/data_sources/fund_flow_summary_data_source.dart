import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/fund_flow_summary_result.dart';

class FundFlowSummaryDataSource {
  static const String _gatewayHost = 'croc-fund-gateway.crocai.workers.dev';

  final http.Client _client;

  FundFlowSummaryDataSource({http.Client? client})
    : _client = client ?? http.Client();

  Future<FundFlowSummaryResult> fetchSummary(String rawFundCode) async {
    final fundCode = _normalizeFundCode(rawFundCode);

    if (fundCode.isEmpty) {
      return FundFlowSummaryResult.unavailable(
        fundCode: '',
        status: 'GEÇERLİ FON KODU GEREKLİ',
      );
    }

    final uri = Uri.https(_gatewayHost, '/', <String, String>{
      'action': 'flow-summary',
      'fund': fundCode,
    });

    try {
      final response = await _client
          .get(
            uri,
            headers: const <String, String>{'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 35));

      if (response.statusCode != 200) {
        return FundFlowSummaryResult.unavailable(
          fundCode: fundCode,
          status: 'Fund Flow Summary HTTP ${response.statusCode}',
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return FundFlowSummaryResult.unavailable(
          fundCode: fundCode,
          status: 'Fund Flow Summary yanıtı geçersiz.',
        );
      }

      if (decoded['available'] != true) {
        return FundFlowSummaryResult.unavailable(
          fundCode: fundCode,
          status:
              decoded['status']?.toString() ??
              decoded['error']?.toString() ??
              'FON AKIŞ ÖZETİ BEKLENİYOR',
        );
      }

      return FundFlowSummaryResult.fromJson(decoded);
    } catch (error) {
      return FundFlowSummaryResult.unavailable(
        fundCode: fundCode,
        status: 'Fon akış özeti alınamadı: $error',
      );
    }
  }

  static String _normalizeFundCode(String value) {
    final code = value.trim().toUpperCase();

    if (!RegExp(r'^[A-Z0-9]{2,10}$').hasMatch(code)) {
      return '';
    }

    return code;
  }
}
