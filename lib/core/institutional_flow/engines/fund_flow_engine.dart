/// CROC AI - Fund Flow Engine
///
/// FUND FLOW V1 SAFETY:
/// Hisse bazli gercek fon akis verisi henuz bagli degil.
///
/// Eski surum hisse sembolunden seed ureterek sentetik fundFlow
/// hesapliyordu. Bu deger finansal veri olmadigi icin CROC karar
/// motoruna girmemelidir.
///
/// Gercek hisse-bazli fon akis kaynagi baglanana kadar bu motor
/// NOTR / 0.0 doner.
///
/// NOT:
/// TEFAS Fon Merkezi ayri bir gercek veri katmanidir.
/// TEFAS fon fiyat/gecmis verisi burada hisse fon akisi gibi
/// yorumlanmaz.
class FundFlowEngine {
  const FundFlowEngine();

  double calculate(String symbol) {
    return 0.0;
  }
}
