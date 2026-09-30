import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/signals/croc_signal_memory_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('restore keeps current session and rejects cross-session observations', () async {
    final day = DateTime(2026, 9, 30, 10);
    SharedPreferences.setMockInitialValues({
      'croc_signal_memory_v1': jsonEncode([
        {
          'id': 'THYAO-2026-09-30-CRAZY',
          'symbol': 'THYAO',
          'engine': 'CRAZY_MONEY_SCANNER',
          'createdAt': day.toIso8601String(),
          'entryPrice': 100.0,
          'score': 75,
          'observations': [
            {
              'observedAt': day.add(const Duration(minutes: 5)).toIso8601String(),
              'high': 102.0,
              'low': 101.0,
              'close': 101.5,
            },
            {
              'observedAt': day.add(const Duration(days: 1)).toIso8601String(),
              'high': 120.0,
              'low': 119.0,
              'close': 119.5,
            },
          ],
        },
        {
          'id': 'OLD',
          'symbol': 'AKBNK',
          'engine': 'CRAZY_MONEY_SCANNER',
          'createdAt': day.subtract(const Duration(days: 1)).toIso8601String(),
          'entryPrice': 50.0,
          'score': 70,
          'observations': const [],
        },
      ]),
    });

    final ledger = await CrocSignalMemoryStore().load(sessionDay: day);
    expect(ledger.signalCount, 1);
    expect(ledger.signal('OLD'), isNull);
    expect(ledger.observations('THYAO-2026-09-30-CRAZY').length, 1);
  });

  test('corrupt persistence payload restores an empty safe ledger', () async {
    SharedPreferences.setMockInitialValues({
      'croc_signal_memory_v1': '{not-json',
    });
    final ledger = await CrocSignalMemoryStore().load(
      sessionDay: DateTime(2026, 9, 30),
    );
    expect(ledger.signalCount, 0);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('croc_signal_memory_v1'), isFalse);
  });

  test('non-list persistence payload is removed after safe restore', () async {
    SharedPreferences.setMockInitialValues({
      'croc_signal_memory_v1': jsonEncode({'unexpected': true}),
    });
    final ledger = await CrocSignalMemoryStore().load(
      sessionDay: DateTime(2026, 9, 30),
    );
    expect(ledger.signalCount, 0);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('croc_signal_memory_v1'), isFalse);
  });
}
