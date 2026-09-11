class BrokerEnvironment {
  BrokerEnvironment._();

  static const String twelveDataApiKey = String.fromEnvironment(
    'TWELVE_DATA_API_KEY',
    defaultValue: '',
  );

  static bool get hasTwelveDataApiKey => twelveDataApiKey.trim().isNotEmpty;

  static const String apiNoktamApiKey = String.fromEnvironment(
    'API_NOKTAM_API_KEY',
    defaultValue: '',
  );

  static bool get hasApiNoktamApiKey => apiNoktamApiKey.trim().isNotEmpty;
}
