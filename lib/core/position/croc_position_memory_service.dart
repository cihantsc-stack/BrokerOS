import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CrocPositionMemoryRecord {
  const CrocPositionMemoryRecord({
    required this.symbol,
    required this.averageCost,
    required this.initialStop,
    required this.initialTarget,
    required this.initialMasterScore,
    required this.initialRiskLabel,
    required this.createdAt,
  });

  final String symbol;
  final double averageCost;
  final double initialStop;
  final double initialTarget;
  final int initialMasterScore;
  final String initialRiskLabel;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'symbol': symbol,
    'averageCost': averageCost,
    'initialStop': initialStop,
    'initialTarget': initialTarget,
    'initialMasterScore': initialMasterScore,
    'initialRiskLabel': initialRiskLabel,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CrocPositionMemoryRecord.fromJson(Map<String, dynamic> json) {
    return CrocPositionMemoryRecord(
      symbol: (json['symbol'] ?? '').toString(),
      averageCost: (json['averageCost'] as num?)?.toDouble() ?? 0,
      initialStop: (json['initialStop'] as num?)?.toDouble() ?? 0,
      initialTarget: (json['initialTarget'] as num?)?.toDouble() ?? 0,
      initialMasterScore: (json['initialMasterScore'] as num?)?.toInt() ?? 0,
      initialRiskLabel: (json['initialRiskLabel'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class CrocPositionMemoryService {
  const CrocPositionMemoryService();

  String _key(String symbol) =>
      'croc_position_memory_v1_${symbol.trim().toUpperCase()}';

  Future<CrocPositionMemoryRecord?> load(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(symbol));
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return CrocPositionMemoryRecord.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(CrocPositionMemoryRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(record.symbol), jsonEncode(record.toJson()));
  }

  Future<void> delete(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(symbol));
  }
}
