# Broker OS Aktif Mimari

## Uygulama

- `lib/main.dart`
- `lib/app/app.dart`
- `lib/app/navigation.dart`
- `lib/app/theme.dart`

## Çekirdek

- `core/models`: veri sözleşmeleri
- `core/repository`: veri erişim sözleşmeleri ve mock uygulamalar
- `core/scanner`: aday tarama
- `core/strategy`: hisse değerlendirme
- `core/engine`: orkestrasyon ve karar motorları
- `core/ai`: AI karar üretimi
- `core/services`: özellik servisleri

## Aktif ekranlar

- Ana Sayfa: `features/mission/decision_center_screen.dart`
- Radar: `features/radar/radar_screen.dart`
- AI: `features/ai/ai_screen.dart`
- Portföy: `features/portfolio/portfolio_screen.dart`
- Profil: `features/profile/profile_screen.dart`
- Hisse Intelligence: `features/intelligence/broker_intelligence_screen.dart`

## Sprint 21 hedefi

`MarketSnapshot` → `BrokerConsensusEngine` → `RiskEngine` → `ConfidenceEngine` → `ExplanationEngine` → `BrokerAiEngine` → `AiDecision`
