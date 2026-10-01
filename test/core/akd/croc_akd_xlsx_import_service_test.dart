import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/desktop_dashboard/services/croc_akd_xlsx_import_service.dart';

void main() {
  const service = CrocAkdXlsxImportService();

  test('extracts BIST symbol from Matriks XLSX file names', () {
    expect(service.symbolFromFileName('THYAO_30.09.2026.xlsx'), 'THYAO');
    expect(service.symbolFromFileName('KOCMT_30.09.2026.xlsx'), 'KOCMT');
    expect(service.symbolFromFileName('ATATR_30.09.2026.xlsx'), 'ATATR');
    expect(service.symbolFromFileName(r'C:\Exports\PASEU_30.09.2026.xlsx'), 'PASEU');
  });

  test('rejects file names without a symbol-like prefix', () {
    expect(service.symbolFromFileName('30.09.2026.xlsx'), isNull);
    expect(service.symbolFromFileName('AKD.xlsx'), 'AKD');
    expect(service.symbolFromFileName('__.xlsx'), isNull);
  });
}
