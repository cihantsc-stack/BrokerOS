import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/akd/croc_windows_matriks_akd_bridge.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const BrokerOSApp());

  if (kDebugMode) {
    Future<void>.delayed(const Duration(seconds: 3), () async {
      try {
        final snapshot = await const CrocWindowsMatriksAkdBridge().readSnapshot();
        if (snapshot == null) {
          debugPrint('CROC_AKD_LIVE: snapshot=null');
          return;
        }
        debugPrint(
          'CROC_AKD_LIVE: symbol=${snapshot.symbol} '
          'institutions=${snapshot.rows.length} '
          'positive=${snapshot.positiveNetLots.toStringAsFixed(0)} '
          'negative=${snapshot.negativeNetLots.toStringAsFixed(0)} '
          'imbalance=${snapshot.netBookImbalancePercent.toStringAsFixed(4)}% '
          'balanced=${snapshot.isBalanced}',
        );
      } catch (error) {
        debugPrint('CROC_AKD_LIVE_ERROR: $error');
      }
    });
  }
}
