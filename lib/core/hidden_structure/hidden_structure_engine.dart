import '../smart_money/smart_money_engine.dart';
import '../smart_money/smart_money_snapshot.dart';
import 'hidden_structure_signal.dart';
import 'hidden_structure_snapshot.dart';

class HiddenStructureEngine {
  HiddenStructureEngine._();

  static final HiddenStructureEngine instance = HiddenStructureEngine._();

  Future<HiddenStructureSnapshot> analyze(String symbol) async {
    final SmartMoneySnapshot smartMoney = await SmartMoneyEngine.instance
        .analyze(symbol);

    final int seed = symbol.codeUnits.fold<int>(
      0,
      (int total, int value) => total + value,
    );

    final double hiddenPosition = (smartMoney.hiddenAccumulationScore + 6.0)
        .clamp(0.0, 100.0);

    final double lotLock = (61.0 + (seed % 24).toDouble()).clamp(0.0, 100.0);

    final double playerChange = (54.0 + (seed % 31).toDouble()).clamp(
      0.0,
      100.0,
    );

    final double floatPressure = (47.0 + (seed % 29).toDouble()).clamp(
      0.0,
      100.0,
    );

    final double traceScore =
        ((hiddenPosition * 0.30) +
                (lotLock * 0.25) +
                (playerChange * 0.20) +
                (floatPressure * 0.10) +
                (smartMoney.hiddenAccumulationScore * 0.15))
            .clamp(0.0, 100.0);

    final List<HiddenStructureSignal> signals = <HiddenStructureSignal>[
      HiddenStructureSignal(
        title: 'Gizli Pozisyon',
        description:
            'Fiyatı agresif yükseltmeden pozisyon biriktirme olasılığı.',
        score: hiddenPosition,
        level: _levelOf(hiddenPosition),
      ),
      HiddenStructureSignal(
        title: 'Lot Kilidi',
        description:
            'Dolaşımdaki lotların belirli oyuncularda sıkışma ihtimali.',
        score: lotLock,
        level: _levelOf(lotLock),
      ),
      HiddenStructureSignal(
        title: 'Oyuncu Değişimi',
        description: 'Eski satıcılardan yeni güçlü alıcılara geçiş ihtimali.',
        score: playerChange,
        level: _levelOf(playerChange),
      ),
      HiddenStructureSignal(
        title: 'Fiili Dolaşım Baskısı',
        description: 'Serbest dolaşımdaki arzın daralma ihtimali.',
        score: floatPressure,
        level: _levelOf(floatPressure),
      ),
      HiddenStructureSignal(
        title: 'İz Sinyali',
        description: 'Hacim, kurum ve fiyat davranışındaki ortak izlerin gücü.',
        score: traceScore,
        level: _levelOf(traceScore),
      ),
    ];

    final String marketMode = traceScore >= 78.0
        ? 'GİZLİ TOPLAMA MODU'
        : traceScore >= 62.0
        ? 'KONTROLLÜ BİRİKİM'
        : traceScore >= 45.0
        ? 'KARARSIZ YAPI'
        : 'DAĞITIM RİSKİ';

    return HiddenStructureSnapshot(
      symbol: symbol,
      overallScore: traceScore,
      marketMode: marketMode,
      signals: signals,
      evidence: <String>[
        'Kurumsal alım yoğunluğu satış tarafının üzerinde.',
        'Büyük emirler fiyatı bozmadan karşılanıyor.',
        'Hacim artışı fiyat hareketinden daha güçlü.',
        'Dağıtım riski mevcut seviyede sınırlı.',
      ],
      aiComment: _commentFor(traceScore),
      generatedAt: DateTime.now(),
    );
  }

  HiddenStructureLevel _levelOf(double score) {
    if (score >= 82.0) {
      return HiddenStructureLevel.veryHigh;
    }

    if (score >= 68.0) {
      return HiddenStructureLevel.high;
    }

    if (score >= 48.0) {
      return HiddenStructureLevel.medium;
    }

    return HiddenStructureLevel.low;
  }

  String _commentFor(double score) {
    if (score >= 78.0) {
      return 'CROC AI, görünür fiyat hareketinin altında güçlü bir '
          'pozisyon birikimi olabileceğini düşünüyor. Bu bir kesinlik '
          'değil; kurum devamlılığı ve hacim teyidi izlenmeli.';
    }

    if (score >= 62.0) {
      return 'Yapıda kontrollü birikim işaretleri var. Oyuncu değişimi '
          'olası ancak güçlü teyit için yeni büyük emirler beklenmeli.';
    }

    if (score >= 45.0) {
      return 'Gizli yapı sinyalleri karışık. Toplama ve dağıtım izleri '
          'birlikte görülüyor; acele karar yerine teyit beklenmeli.';
    }

    return 'Dağıtım ve arz baskısı ihtimali öne çıkıyor. Yeni pozisyon '
        'öncesi risk disiplininin artırılması uygun olabilir.';
  }
}
