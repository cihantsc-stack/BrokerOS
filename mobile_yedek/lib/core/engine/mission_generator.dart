import 'broker_engine.dart';

class MissionGenerator {
  static String morningMission() {
    final list = BrokerEngine.run();

    final best = list.first;

    return '''
Günaydın.

Bugün ${list.length} güçlü fırsat tespit edildi.

En güçlü hisse:

${best.symbol}

AI Skoru: ${best.aiScore}

Karar: ${best.decision}

Bugünkü görev:

✓ ${best.symbol} takip et

✓ Kurumsal para akışını izle

✓ Smart Money yönünü kontrol et

✓ Stop seviyesine sadık kal
''';
  }
}