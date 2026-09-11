enum MarketAssetType { bist, viop, forex, gold, crypto, tefas }

extension MarketAssetTypeLabel on MarketAssetType {
  String get label {
    switch (this) {
      case MarketAssetType.bist:
        return 'BIST';
      case MarketAssetType.viop:
        return 'VİOP';
      case MarketAssetType.forex:
        return 'DÖVİZ';
      case MarketAssetType.gold:
        return 'ALTIN';
      case MarketAssetType.crypto:
        return 'KRİPTO';
      case MarketAssetType.tefas:
        return 'TEFAS';
    }
  }
}
