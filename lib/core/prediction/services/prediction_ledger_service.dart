import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/stock_analysis.dart';
import '../engines/croc_prediction_engine.dart';
import '../models/prediction_horizon.dart';

class PredictionLedgerService {
  PredictionLedgerService._();

  static final PredictionLedgerService instance = PredictionLedgerService._();

  static const String _storageKey = 'croc_prediction_ledger_v3';

  Future<void> captureAndReconcile(StockAnalysis stock) async {
    final price = stock.lastPrice ?? stock.entry;

    if (price <= 0) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final records = _readRecords(prefs);

    final now = DateTime.now();
    final symbol = stock.symbol.toUpperCase();

    _reconcile(records: records, symbol: symbol, currentPrice: price, now: now);

    final alreadyCapturedToday = records.any(
      (record) =>
          record['symbol'] == symbol &&
          _sameDay(
            DateTime.tryParse(record['createdAt']?.toString() ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0),
            now,
          ),
    );

    if (!alreadyCapturedToday) {
      final predictions = const CrocPredictionEngine().analyze(stock);

      final predictionMap = <String, dynamic>{};

      for (final prediction in predictions) {
        predictionMap[prediction.horizon.name] = <String, dynamic>{
          'modelProbability': prediction.modelProbability,
          'confidence': prediction.confidence,
          'riskScore': prediction.riskScore,
          'direction': prediction.direction,
          'regime': prediction.regime,
        };
      }

      records.insert(0, <String, dynamic>{
        'id': '${symbol}_${now.microsecondsSinceEpoch}',
        'symbol': symbol,
        'createdAt': now.toIso8601String(),
        'referencePrice': price,
        'technicalScore': stock.technicalScore,
        'smartMoneyScore': stock.smartMoneyScore,
        'institutionalScore': stock.institutionalScore,
        'momentumScore': stock.momentumScore,
        'newsScore': stock.newsScore,
        'riskScore': stock.riskScore,
        'activeSignalCount': stock.activeSignalCount,
        'predictions': predictionMap,
        'outcomes': <String, dynamic>{},
      });
    }

    await prefs.setString(_storageKey, jsonEncode(records));
  }

  Future<List<Map<String, dynamic>>> recordsFor(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    final records = _readRecords(prefs);
    final normalized = symbol.toUpperCase();

    return records
        .where((record) => record['symbol']?.toString() == normalized)
        .toList();
  }

  Future<Map<String, dynamic>> accuracyFor(String symbol) async {
    final records = await recordsFor(symbol);

    final result = <String, dynamic>{};

    for (final horizon in PredictionHorizon.values) {
      var resolved = 0;
      var successful = 0;
      var totalReturn = 0.0;

      for (final record in records) {
        final outcomes = _map(record['outcomes']);

        final outcome = _map(outcomes[horizon.name]);

        if (outcome.isEmpty) {
          continue;
        }

        resolved++;

        if (outcome['successful'] == true) {
          successful++;
        }

        totalReturn += _double(outcome['returnPct']);
      }

      result[horizon.name] = <String, dynamic>{
        'resolved': resolved,
        'successful': successful,
        'successRate': resolved == 0 ? 0.0 : successful / resolved * 100,
        'averageReturnPct': resolved == 0 ? 0.0 : totalReturn / resolved,
      };
    }

    return result;
  }

  List<Map<String, dynamic>> _readRecords(SharedPreferences prefs) {
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.trim().isEmpty) {
      return <Map<String, dynamic>>[];
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        return <Map<String, dynamic>>[];
      }

      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  void _reconcile({
    required List<Map<String, dynamic>> records,
    required String symbol,
    required double currentPrice,
    required DateTime now,
  }) {
    for (final record in records) {
      if (record['symbol']?.toString() != symbol) {
        continue;
      }

      final createdAt = DateTime.tryParse(
        record['createdAt']?.toString() ?? '',
      );

      final referencePrice = _double(record['referencePrice']);

      if (createdAt == null || referencePrice <= 0) {
        continue;
      }

      final predictions = _map(record['predictions']);

      final outcomes = _map(record['outcomes']);

      for (final horizon in PredictionHorizon.values) {
        if (outcomes.containsKey(horizon.name)) {
          continue;
        }

        final maturedAt = _addTradingDays(createdAt, horizon.tradingDays);

        if (now.isBefore(maturedAt)) {
          continue;
        }

        final prediction = _map(predictions[horizon.name]);

        if (prediction.isEmpty) {
          continue;
        }

        final returnPct =
            ((currentPrice - referencePrice) / referencePrice) * 100;

        final direction =
            prediction['direction']?.toString().toUpperCase() ?? '';

        final successful = _isSuccessful(
          direction: direction,
          returnPct: returnPct,
        );

        outcomes[horizon.name] = <String, dynamic>{
          'maturedAt': maturedAt.toIso8601String(),
          'resolvedAt': now.toIso8601String(),
          'resolvedPrice': currentPrice,
          'returnPct': returnPct,
          'successful': successful,
        };
      }

      record['outcomes'] = outcomes;
    }
  }

  bool _isSuccessful({required String direction, required double returnPct}) {
    if (direction.contains('POZ')) {
      return returnPct > 0;
    }

    if (direction.contains('NEG') || direction == 'ZAYIF') {
      return returnPct < 0;
    }

    return returnPct.abs() <= 1.0;
  }

  DateTime _addTradingDays(DateTime start, int tradingDays) {
    var cursor = start;
    var added = 0;

    while (added < tradingDays) {
      cursor = cursor.add(const Duration(days: 1));

      if (cursor.weekday == DateTime.saturday ||
          cursor.weekday == DateTime.sunday) {
        continue;
      }

      added++;
    }

    return cursor;
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  double _double(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
