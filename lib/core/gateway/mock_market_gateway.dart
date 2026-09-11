import 'data_source_status.dart';
import 'market_gateway.dart';

class MockMarketGateway implements MarketGateway {
  const MockMarketGateway();

  @override
  Future<List<DataSourceStatus>> checkSources() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final DateTime now = DateTime.now();

    return <DataSourceStatus>[
      DataSourceStatus(
        id: 'market',
        name: 'Piyasa Verisi',
        description: 'Fiyat, değişim, hacim ve endeks verileri',
        state: DataSourceState.connected,
        checkedAt: now,
      ),
      DataSourceStatus(
        id: 'news',
        name: 'Haber Akışı',
        description: 'Şirket haberleri ve duygu analizi',
        state: DataSourceState.connected,
        checkedAt: now,
      ),
      DataSourceStatus(
        id: 'institution',
        name: 'Kurumsal Para',
        description: 'Kurum hareketleri ve Smart Money sinyalleri',
        state: DataSourceState.delayed,
        delay: const Duration(minutes: 15),
        checkedAt: now,
      ),
      DataSourceStatus(
        id: 'fund',
        name: 'Fon Verisi',
        description: 'Fon akışı ve portföy eğilimleri',
        state: DataSourceState.connected,
        checkedAt: now,
      ),
      DataSourceStatus(
        id: 'kap',
        name: 'KAP Bildirimleri',
        description: 'Şirket açıklamaları ve önemli gelişmeler',
        state: DataSourceState.planned,
        checkedAt: now,
      ),
      DataSourceStatus(
        id: 'macro',
        name: 'Makro Veri',
        description: 'TCMB, faiz, kur ve risk göstergeleri',
        state: DataSourceState.planned,
        checkedAt: now,
      ),
    ];
  }
}
