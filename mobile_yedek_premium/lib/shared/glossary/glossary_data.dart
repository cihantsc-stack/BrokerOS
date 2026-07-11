class GlossaryItem {
  final String title;
  final String description;
  final String aiNote;

  const GlossaryItem({
    required this.title,
    required this.description,
    required this.aiNote,
  });
}

class GlossaryData {
  GlossaryData._();

  static final Map<String, GlossaryItem> terms = {
    'Smart Money': const GlossaryItem(
      title: 'Smart Money',
      description: 'Büyük fonlar, kurumlar ve profesyonel yatırımcıların piyasadaki para hareketlerini ifade eder.',
      aiNote: 'CROC AI notu: Tek başına alım kararı değildir; teknik, risk ve hacimle birlikte okunur.',
    ),
    'Momentum': const GlossaryItem(
      title: 'Momentum',
      description: 'Bir hissenin yükseliş veya düşüş hızını gösterir. Güçlü momentum, hareketin devam etme ihtimalini artırabilir.',
      aiNote: 'CROC AI notu: Momentum güçlü ama hacim zayıfsa sinyal güveni düşer.',
    ),
    'RSI': const GlossaryItem(
      title: 'RSI',
      description: '0 ile 100 arasında çalışan momentum göstergesidir. 70 üzeri aşırı alım, 30 altı aşırı satım bölgesi olarak yorumlanır.',
      aiNote: 'CROC AI notu: RSI tek başına al/sat sinyali değildir.',
    ),
    'MACD': const GlossaryItem(
      title: 'MACD',
      description: 'Trendin yönünü ve gücünü anlamaya yardımcı olan teknik göstergedir.',
      aiNote: 'CROC AI notu: MACD sinyali kurum akışı ve fiyat bölgesiyle birlikte daha anlamlıdır.',
    ),
    'Volatilite': const GlossaryItem(
      title: 'Volatilite',
      description: 'Fiyatın ne kadar sert ve hızlı dalgalandığını gösterir. Volatilite yükseldikçe risk de artabilir.',
      aiNote: 'CROC AI notu: Yüksek volatilitede stop disiplini daha kritik hale gelir.',
    ),
    'Destek': const GlossaryItem(
      title: 'Destek',
      description: 'Fiyatın düşerken tutunma ihtimalinin yüksek olduğu bölgedir.',
      aiNote: 'CROC AI notu: Destek kırılırsa pozitif senaryo zayıflayabilir.',
    ),
    'Direnç': const GlossaryItem(
      title: 'Direnç',
      description: 'Fiyatın yükselirken zorlanabileceği bölgedir.',
      aiNote: 'CROC AI notu: Direnç güçlü hacimle kırılırsa yeni hedef bölgesi açılabilir.',
    ),
    'Stop': const GlossaryItem(
      title: 'Stop',
      description: 'Zararı sınırlamak için önceden belirlenen çıkış seviyesidir.',
      aiNote: 'CROC AI notu: Stop seviyesi bozulursa işlem fikri yeniden değerlendirilir.',
    ),
    'Broker Consensus': const GlossaryItem(
      title: 'Broker Consensus',
      description: 'Teknik analiz, kurum hareketleri, haber etkisi, momentum ve risk verilerinin birleşik karar puanıdır.',
      aiNote: 'CROC AI notu: Consensus yüksekse karar güveni artar; düşükse beklemek daha sağlıklı olabilir.',
    ),
    'Game Theory': const GlossaryItem(
      title: 'Game Theory',
      description: 'Piyasadaki büyük oyuncuların muhtemel davranışlarını senaryo olarak analiz etme yaklaşımıdır.',
      aiNote: 'CROC AI notu: Büyük oyuncunun fiyatı nereye çekmek isteyebileceği bu modülde yorumlanır.',
    ),
  };

  static GlossaryItem? find(String term) => terms[term];
}
