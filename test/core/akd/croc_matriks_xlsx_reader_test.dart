import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/akd/croc_matriks_akd_adapter.dart';
import 'package:mobile/core/akd/croc_matriks_xlsx_reader.dart';
import 'package:mobile/core/signals/croc_institutional_flow_store.dart';
import 'package:mobile/core/signals/croc_institutional_strength_engine.dart';

void main() {
  final store = CrocInstitutionalFlowStore.instance;
  const reader = CrocMatriksXlsxReader();
  const adapter = CrocMatriksAkdAdapter();
  final now = DateTime.utc(2026, 9, 30, 12);

  setUp(store.clear);
  tearDown(store.clear);

  Uint8List workbookBytes(List<List<CellValue?>> rows) {
    final excel = Excel.createExcel();
    final sheet = excel['AKD'];
    for (final row in rows) {
      sheet.appendRow(row);
    }
    final bytes = excel.save();
    return Uint8List.fromList(bytes!);
  }

  test('reads Matriks XLSX bytes and imports healthy AKD end to end', () {
    final bytes = workbookBytes([
      [TextCellValue('Matriks AKD Export')],
      [TextCellValue('Araci Kurum'),TextCellValue('Alis'),TextCellValue('Ortalama'),TextCellValue('Satis'),TextCellValue('Ortalama'),TextCellValue('Toplam'),TextCellValue('Yuzde'),TextCellValue('Net'),TextCellValue('Maliyet')],
      [TextCellValue('YAPI KREDI'),IntCellValue(7701159),DoubleCellValue(288.696),IntCellValue(5358781),DoubleCellValue(288.693),IntCellValue(13059940),DoubleCellValue(18.935),IntCellValue(2342378),DoubleCellValue(288.704)],
      [TextCellValue('DENIZ'),IntCellValue(991777),DoubleCellValue(289.2),IntCellValue(3334155),DoubleCellValue(289.8),IntCellValue(4325932),IntCellValue(6),IntCellValue(-2342378),DoubleCellValue(289.796)],
    ]);

    final table = reader.read(bytes);
    expect(table, hasLength(3));
    expect(table.first.first, 'Araci Kurum');

    final ok = adapter.import(
      symbol: 'THYAO',
      table: table,
      source: CrocInstitutionalSource(provider: 'MATRIKS_XLSX', observedAt: now, authenticated: true),
      asOf: now,
      store: store,
    );
    expect(ok, isTrue);
    expect(store.report('THYAO', asOf: now)?.topNetBuyer?.participant, 'YAPI KREDI');
  });

  test('returns empty table when workbook has no AKD header', () {
    final bytes = workbookBytes([
      [TextCellValue('Not an AKD export')],
      [TextCellValue('foo'), TextCellValue('bar')],
    ]);
    expect(reader.read(bytes), isEmpty);
  });
}
