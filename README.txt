CROC FUND FLOW SUMMARY V2 - HAZIR DOSYALAR

ZIP içindeki klasör yapısını BrokerOS_Desktop kök klasörüne kopyalayın.

Dosyalar:
1) lib/core/funds/models/fund_flow_summary_result.dart
2) lib/core/funds/data_sources/fund_flow_summary_data_source.dart
3) lib/features/funds/funds_screen.dart

Mevcut tefas_fund_data_source.dart dosyasına DOKUNULMADI.

Sonra:
dart format .\lib\core\funds\models\fund_flow_summary_result.dart .\lib\core\funds\data_sources\fund_flow_summary_data_source.dart .\lib\features\funds\funds_screen.dart
dart analyze .\lib\core\funds\models\fund_flow_summary_result.dart
dart analyze .\lib\core\funds\data_sources\fund_flow_summary_data_source.dart
dart analyze .\lib\features\funds\funds_screen.dart
flutter run -d chrome
