import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'croc_signal_memory_engine.dart';
import 'croc_signal_memory_ledger.dart';

/// Persists scanner memory only. It never invents market observations.
class CrocSignalMemoryStore {
  static const String _key = 'croc_signal_memory_v1';

  Future<void> save(CrocSignalMemoryLedger ledger) async {
    final payload = ledger.signals.map((signal) {
      return <String, dynamic>{
        'id': signal.id,
        'symbol': signal.symbol,
        'engine': signal.engine,
        'createdAt': signal.createdAt.toIso8601String(),
        'entryPrice': signal.entryPrice,
        'score': signal.score,
        'targetPrice': signal.targetPrice,
        'stopPrice': signal.stopPrice,
        'observations': ledger.observations(signal.id).map((observation) {
          return <String, dynamic>{
            'observedAt': observation.observedAt.toIso8601String(),
            'high': observation.high,
            'low': observation.low,
            'close': observation.close,
          };
        }).toList(growable: false),
      };
    }).toList(growable: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(payload));
  }

  Future<CrocSignalMemoryLedger> load({DateTime? sessionDay}) async {
    final ledger = CrocSignalMemoryLedger();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return ledger;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return ledger;
      final day = sessionDay ?? DateTime.now();
      for (final item in decoded) {
        if (item is! Map) continue;
        final createdAt = DateTime.tryParse(item['createdAt']?.toString() ?? '');
        final entryPrice = (item['entryPrice'] as num?)?.toDouble();
        final score = (item['score'] as num?)?.toInt();
        if (createdAt == null ||
            entryPrice == null ||
            score == null ||
            !_sameDay(createdAt, day)) {
          continue;
        }
        final signal = CrocSignalSnapshot(
          id: item['id']?.toString() ?? '',
          symbol: item['symbol']?.toString() ?? '',
          engine: item['engine']?.toString() ?? '',
          createdAt: createdAt,
          entryPrice: entryPrice,
          score: score,
          targetPrice: (item['targetPrice'] as num?)?.toDouble(),
          stopPrice: (item['stopPrice'] as num?)?.toDouble(),
        );
        if (!ledger.recordSignal(signal)) continue;
        final observations = item['observations'];
        if (observations is! List) continue;
        for (final point in observations) {
          if (point is! Map) continue;
          final observedAt =
              DateTime.tryParse(point['observedAt']?.toString() ?? '');
          final high = (point['high'] as num?)?.toDouble();
          final low = (point['low'] as num?)?.toDouble();
          final close = (point['close'] as num?)?.toDouble();
          if (observedAt == null || high == null || low == null || close == null) {
            continue;
          }
          ledger.recordObservation(
            signal.id,
            CrocSignalObservation(
              observedAt: observedAt,
              high: high,
              low: low,
              close: close,
            ),
          );
        }
      }
    } catch (_) {
      return CrocSignalMemoryLedger();
    }
    return ledger;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
