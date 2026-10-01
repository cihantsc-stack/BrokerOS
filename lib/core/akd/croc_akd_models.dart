enum CrocAkdDataFlag { negativeCost, zeroBuy, zeroSell, netMismatch }

class CrocAkdBrokerRow {
  const CrocAkdBrokerRow({required this.institution, required this.buyLots, required this.buyAverage, required this.sellLots, required this.sellAverage, required this.totalLots, required this.sharePercent, required this.netLots, required this.cost});
  final String institution; final double buyLots; final double buyAverage; final double sellLots; final double sellAverage; final double totalLots; final double sharePercent; final double netLots; final double cost;
  List<CrocAkdDataFlag> get dataFlags {
    final flags=<CrocAkdDataFlag>[];
    if(cost<0) flags.add(CrocAkdDataFlag.negativeCost);
    if(buyLots==0) flags.add(CrocAkdDataFlag.zeroBuy);
    if(sellLots==0) flags.add(CrocAkdDataFlag.zeroSell);
    if(((buyLots-sellLots)-netLots).abs()>1.0) flags.add(CrocAkdDataFlag.netMismatch);
    return List.unmodifiable(flags);
  }
  bool get isUsable => institution.trim().isNotEmpty && buyLots.isFinite && sellLots.isFinite && totalLots.isFinite && netLots.isFinite && buyLots>=0 && sellLots>=0 && totalLots>=0;
}
enum CrocAkdConcentrationSignal { buyerConcentrated, sellerConcentrated, balanced }
class CrocAkdResult {
  const CrocAkdResult({required this.rows,required this.topBuyers,required this.topSellers,required this.positiveNetLots,required this.negativeNetLots,required this.buyerConcentrationPercent,required this.sellerConcentrationPercent,required this.turnoverConcentrationPercent,required this.signal});
  final List<CrocAkdBrokerRow> rows,topBuyers,topSellers; final double positiveNetLots,negativeNetLots,buyerConcentrationPercent,sellerConcentrationPercent,turnoverConcentrationPercent; final CrocAkdConcentrationSignal signal;
}
