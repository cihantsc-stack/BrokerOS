# Broker OS — Sprint 20.5 Architecture Cleanup

## Yapılanlar

- Aktif ana ekran olarak `features/mission/decision_center_screen.dart` korundu.
- Kullanılmayan eski `features/decision_center/` kopyası kaldırıldı.
- Kullanılmayan `lib/widget/intelligence/` kopyası kaldırıldı.
- Aktif Intelligence ekranı kendi dahili widget yapısıyla korundu; kullanılmayan `features/intelligence/widgets/` kopyası kaldırıldı.
- `core/services/risk_engine.dart` kaldırıldı; tek Risk Engine olarak `core/engine/risk_engine.dart` bırakıldı.
- Yanlış isimli/eski `core/analysis_service.dart` kaldırıldı; gerçek servis `core/services/analysis_service.dart` olarak korundu.
- `decision_center_screen_yedek.dart` kaldırıldı.
- Derleme çıktıları ve yerel makine dosyaları paketten çıkarıldı (`build/`, `.dart_tool/`, `android/local.properties`).

## Aktif temel akış

`main.dart` → `BrokerOSApp` → `BrokerNavigation` → `features/mission/DecisionCenterScreen`

## Korunan çekirdek yapı

- Repository Layer
- Scanner ve Strategy Engine
- Broker Engine
- Market Consensus Engine
- Yeni Risk Assessment ve Risk Engine
- Radar, Intelligence, AI, Portfolio ve Profile ekranları

## Not

Bu sprint davranış değiştiren yeni özellik eklemez. Amaç çalışan sürümü bozmadan yinelenen ve eski kaynakları temizleyerek Sprint 21 AI Pipeline için tek mimari taban oluşturmaktır.
