enum InstitutionalDirection { strongBuy, buy, neutral, sell, strongSell }

extension InstitutionalDirectionLabel on InstitutionalDirection {
  String get label {
    switch (this) {
      case InstitutionalDirection.strongBuy:
        return 'GÜÇLÜ ALIM';
      case InstitutionalDirection.buy:
        return 'ALIM';
      case InstitutionalDirection.neutral:
        return 'NÖTR';
      case InstitutionalDirection.sell:
        return 'SATIM';
      case InstitutionalDirection.strongSell:
        return 'GÜÇLÜ SATIM';
    }
  }
}
