enum ConnectionStatus { online, degraded, offline }

extension ConnectionStatusLabel on ConnectionStatus {
  String get label {
    switch (this) {
      case ConnectionStatus.online:
        return 'ÇEVRİMİÇİ';
      case ConnectionStatus.degraded:
        return 'YAVAŞ BAĞLANTI';
      case ConnectionStatus.offline:
        return 'ÇEVRİMDIŞI';
    }
  }
}
