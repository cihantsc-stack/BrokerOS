CROC Prediction UI V1

1) ZIP'i BrokerOS_Desktop proje klasörüne açın.
2) PowerShell proje kökünde iken:
   powershell -ExecutionPolicy Bypass -File .\install_prediction_ui.ps1
3) Ardından:
   dart analyze .\lib\features\intelligence\widgets\croc_prediction_shadow_card.dart
4) Sonra:
   flutter run -d chrome

Installer broker_intelligence_screen.dart dosyasının otomatik yedeğini alır.
