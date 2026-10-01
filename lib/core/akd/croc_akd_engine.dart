import 'croc_akd_models.dart';

class CrocAkdEngine {
  const CrocAkdEngine({this.topCount=5});
  final int topCount;
  CrocAkdResult analyze(Iterable<CrocAkdBrokerRow> source) {
    if(topCount<1) throw ArgumentError.value(topCount,'topCount','must be at least 1');
    final rows=source.where((r)=>r.isUsable).toList(growable:false);
    final buyers=rows.where((r)=>r.netLots>0).toList()..sort((a,b)=>b.netLots.compareTo(a.netLots));
    final sellers=rows.where((r)=>r.netLots<0).toList()..sort((a,b)=>a.netLots.compareTo(b.netLots));
    final topBuyers=buyers.take(topCount).toList(growable:false);
    final topSellers=sellers.take(topCount).toList(growable:false);
    final positive=_sum(buyers.map((r)=>r.netLots));
    final negative=_sum(sellers.map((r)=>r.netLots.abs()));
    final buyerPct=_percent(_sum(topBuyers.map((r)=>r.netLots)),positive);
    final sellerPct=_percent(_sum(topSellers.map((r)=>r.netLots.abs())),negative);
    final byTurnover=rows.toList()..sort((a,b)=>b.totalLots.compareTo(a.totalLots));
    final turnover=_sum(rows.map((r)=>r.totalLots));
    final turnoverPct=_percent(_sum(byTurnover.take(topCount).map((r)=>r.totalLots)),turnover);
    final gap=buyerPct-sellerPct;
    final signal=gap>=10?CrocAkdConcentrationSignal.buyerConcentrated:gap<=-10?CrocAkdConcentrationSignal.sellerConcentrated:CrocAkdConcentrationSignal.balanced;
    return CrocAkdResult(rows:List.unmodifiable(rows),topBuyers:List.unmodifiable(topBuyers),topSellers:List.unmodifiable(topSellers),positiveNetLots:positive,negativeNetLots:negative,buyerConcentrationPercent:buyerPct,sellerConcentrationPercent:sellerPct,turnoverConcentrationPercent:turnoverPct,signal:signal);
  }
  double _sum(Iterable<double> values)=>values.fold(0,(sum,value)=>sum+value);
  double _percent(double part,double whole)=>whole>0?(part/whole)*100:0;
}
