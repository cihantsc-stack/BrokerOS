import 'package:flutter/material.dart';

import 'features/desktop_dashboard/services/crazy_money_fast_scanner_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('');
  print('============================================================');
  print('CROC FAST MONEY CACHE TEST BASLIYOR');
  print('============================================================');

  // 1. TARAMA
  final firstWatch = Stopwatch()..start();

  print('');
  print('>>> 1. TARAMA BASLIYOR');
  await CrazyMoneyFastScannerService.instance.scan(concurrency: 20);

  firstWatch.stop();

  print('');
  print(
    '>>> 1. TARAMA BITTI | '
    '${(firstWatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} SN',
  );

  // 2. TARAMA - AYNI PROCESS / MEMORY CACHE
  final secondWatch = Stopwatch()..start();

  print('');
  print('>>> 2. TARAMA BASLIYOR - MEMORY CACHE BEKLENIYOR');
  await CrazyMoneyFastScannerService.instance.scan(concurrency: 20);

  secondWatch.stop();

  print('');
  print(
    '>>> 2. TARAMA BITTI | '
    '${(secondWatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} SN',
  );

  print('');
  print('============================================================');
  print('CROC FAST MONEY CACHE TEST TAMAMLANDI');
  print(
    '1. TARAMA : '
    '${(firstWatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} SN',
  );
  print(
    '2. TARAMA : '
    '${(secondWatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} SN',
  );
  print('============================================================');
}
