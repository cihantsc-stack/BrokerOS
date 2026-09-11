import 'app_language.dart';

class AppTranslations {
  static const Map<AppLanguage, Map<String, String>> _translations = {
    AppLanguage.turkish: {
      'app_name': 'Broker OS',

      'home': 'Ana Sayfa',
      'radar': 'Radar',
      'markets': 'Piyasalar',
      'portfolio': 'Portföy',
      'ai': 'Yapay Zekâ',
      'croc_ai': 'CROC AI',
      'profile': 'Profil',
      'settings': 'Ayarlar',

      'language': 'Dil',
      'turkish': 'Türkçe',
      'english': 'English',

      'decision_center': 'Karar Merkezi',
      'experience_center': 'Yapay Zekâ Deneyim Merkezi',
      'play_analysis': 'Analizi Oynat',
      'chart_xray': 'Grafik Röntgeni',
      'stock_character': 'Hisse Karakteri',
      'stock_comparison': 'Hisse Karşılaştırması',
      'money_flow_map': 'Para Akış Haritası',
      'decision_room': 'Karar Odası',

      'simple_mode': 'Karar Modu',
      'professional_mode': 'Uzman İşlem Modu',

      'buy': 'Al',
      'sell': 'Sat',
      'wait': 'Bekle',
      'hold_cash': 'Nakit Bekle',

      'confidence': 'Güven',
      'risk': 'Risk',
      'low': 'Düşük',
      'medium': 'Orta',
      'high': 'Yüksek',

      'scan_completed': 'Piyasa taraması tamamlandı',
      'stocks_scanned': 'Hisse tarandı',
      'signals_analyzed': 'Sinyal analiz edildi',
      'show_reason': 'Nedenini Göster',
      'no_clear_pattern': 'Belirgin formasyon yok',

      'institutional_flow': 'Kurumsal Para Akışı',
      'smart_money': 'Büyük Oyuncu Hareketleri',
      'support_zone': 'Destek Bölgesi',
      'resistance_zone': 'Direnç Bölgesi',
      'target': 'Hedef',
      'stop': 'Zarar Kes',
    },

    AppLanguage.english: {
      'app_name': 'Broker OS',

      'home': 'Home',
      'radar': 'Radar',
      'markets': 'Markets',
      'portfolio': 'Portfolio',
      'ai': 'Artificial Intelligence',
      'croc_ai': 'CROC AI',
      'profile': 'Profile',
      'settings': 'Settings',

      'language': 'Language',
      'turkish': 'Türkçe',
      'english': 'English',

      'decision_center': 'Decision Center',
      'experience_center': 'AI Experience Center',
      'play_analysis': 'Play Analysis',
      'chart_xray': 'Chart X-Ray',
      'stock_character': 'Stock Character',
      'stock_comparison': 'Stock Comparison',
      'money_flow_map': 'Money Flow Map',
      'decision_room': 'Decision Room',

      'simple_mode': 'Decision Mode',
      'professional_mode': 'Trader Mode',

      'buy': 'Buy',
      'sell': 'Sell',
      'wait': 'Wait',
      'hold_cash': 'Stay in Cash',

      'confidence': 'Confidence',
      'risk': 'Risk',
      'low': 'Low',
      'medium': 'Medium',
      'high': 'High',

      'scan_completed': 'Market scan completed',
      'stocks_scanned': 'Stocks scanned',
      'signals_analyzed': 'Signals analyzed',
      'show_reason': 'Show Reason',
      'no_clear_pattern': 'No clear pattern',

      'institutional_flow': 'Institutional Money Flow',
      'smart_money': 'Smart Money Activity',
      'support_zone': 'Support Zone',
      'resistance_zone': 'Resistance Zone',
      'target': 'Target',
      'stop': 'Stop Loss',
    },
  };

  static String translate({
    required AppLanguage language,
    required String key,
  }) {
    return _translations[language]?[key] ?? key;
  }
}
