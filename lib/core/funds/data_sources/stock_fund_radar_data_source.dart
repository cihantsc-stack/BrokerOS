import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/stock_fund_radar_result.dart';

class StockFundRadarDataSource {
  static const String _gatewayHost = 'croc-fund-gateway.crocai.workers.dev';

  final http.Client _client;

  StockFundRadarDataSource({http.Client? client})
    : _client = client ?? http.Client();

  Future<StockFundRadarResult> fetch(String rawSymbol) async {
    final symbol = _normalizeSymbol(rawSymbol);

    if (symbol.isEmpty) {
      return StockFundRadarResult.unavailable(
        symbol: '',
        status: 'GEÇERLİ HİSSE KODU GEREKLİ',
      );
    }

    final uri = Uri.https(_gatewayHost, '/', <String, String>{
      'action': 'stock-funds-kv',
      'symbol': symbol,
    });

    try {
      final response = await _client
          .get(
            uri,
            headers: const <String, String>{'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return StockFundRadarResult.unavailable(
          symbol: symbol,
          status: 'FON RADARI HTTP ${response.statusCode}',
        );
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return StockFundRadarResult.unavailable(
          symbol: symbol,
          status: 'FON RADARI YANITI GEÇERSİZ',
        );
      }

      if (decoded['available'] != true) {
        return StockFundRadarResult.fromJson(decoded);
      }

      return StockFundRadarResult.fromJson(decoded);
    } catch (error) {
      return StockFundRadarResult.unavailable(
        symbol: symbol,
        status: 'Fon radarı alınamadı: $error',
      );
    }
  }

  static String _normalizeSymbol(String value) {
    final symbol = value.trim().toUpperCase();

    if (!RegExp(r'^[A-Z0-9]{2,12}$').hasMatch(symbol)) {
      return '';
    }

    return symbol;
  }
}
