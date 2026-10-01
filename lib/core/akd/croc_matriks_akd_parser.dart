import 'croc_akd_models.dart';

class CrocMatriksAkdParser {
  const CrocMatriksAkdParser();
  List<CrocAkdBrokerRow> parseRows(List<List<Object?>> table) {
    if(table.isEmpty) return const [];
    final start=_header(table.first)?1:0;
    final out=<CrocAkdBrokerRow>[];
    for(var i=start;i<table.length;i++){
      final cells=table[i]; if(cells.length<9) continue;
      final institution='${cells[0] ?? ''}'.trim(); if(institution.isEmpty) continue;
      final row=CrocAkdBrokerRow(institution:institution,buyLots:_number(cells[1]),buyAverage:_number(cells[2]),sellLots:_number(cells[3]),sellAverage:_number(cells[4]),totalLots:_number(cells[5]),sharePercent:_number(cells[6]),netLots:_number(cells[7]),cost:_number(cells[8]));
      if(row.isUsable) out.add(row);
    }
    return List.unmodifiable(out);
  }
  bool _header(List<Object?> row)=>row.isNotEmpty && '${row.first ?? ''}'.toLowerCase().contains('kurum');
  double _number(Object? value) {
    if(value is num) return value.toDouble();
    var s='${value ?? ''}'.trim().replaceAll(' ',''); if(s.isEmpty) return double.nan;
    if(s.contains(',')&&s.contains('.')) {
      s=s.lastIndexOf(',')>s.lastIndexOf('.')?s.replaceAll('.','').replaceAll(',','.'):s.replaceAll(',','');
    } else if(s.contains(',')) { s=s.replaceAll(',','.'); }
    return double.tryParse(s)??double.nan;
  }
}
