import 'dart:typed_data';

import '../../../core/akd/croc_matriks_akd_adapter.dart';
import '../../../core/akd/croc_matriks_xlsx_reader.dart';
import '../../../core/signals/croc_institutional_strength_engine.dart';

class CrocAkdXlsxImportResult {
  const CrocAkdXlsxImportResult({
    required this.accepted,
    required this.symbol,
    required this.message,
  });

  final bool accepted;
  final String? symbol;
  final String message;
}

/// UI-independent XLSX import coordinator. File picking stays in the desktop UI.
class CrocAkdXlsxImportService {
  const CrocAkdXlsxImportService({
    this.reader = const CrocMatriksXlsxReader(),
    this.adapter = const CrocMatriksAkdAdapter(),
  });

  final CrocMatriksXlsxReader reader;
  final CrocMatriksAkdAdapter adapter;

  String? symbolFromFileName(String fileName) {
    final name = fileName.trim().split(RegExp(r'[\\/]')).last;
    final match = RegExp(r'^([A-Za-z0-9]{3,8})(?:[_ .-]|$)').firstMatch(name);
    return match?.group(1)?.toUpperCase();
  }

  CrocAkdXlsxImportResult importBytes({
    required String fileName,
    required Uint8List bytes,
    required DateTime observedAt,
    DateTime? asOf,
  }) {
    final symbol = symbolFromFileName(fileName);
    if (symbol == null) {
      return const CrocAkdXlsxImportResult(
        accepted: false,
        symbol: null,
        message: 'Dosya adından hisse kodu okunamadı.',
      );
    }

    final table = reader.read(bytes);
    if (table.isEmpty) {
      return CrocAkdXlsxImportResult(
        accepted: false,
        symbol: symbol,
        message: 'Excel içinde geçerli Matriks AKD tablosu bulunamadı.',
      );
    }

    final accepted = adapter.import(
      symbol: symbol,
      table: table,
      source: CrocInstitutionalSource(
        provider: 'MATRIKS_XLSX_MANUAL',
        observedAt: observedAt,
        authenticated: true,
      ),
      asOf: asOf ?? DateTime.now(),
    );

    return CrocAkdXlsxImportResult(
      accepted: accepted,
      symbol: symbol,
      message: accepted
          ? '$symbol AKD başarıyla yüklendi.'
          : '$symbol AKD güvenlik kontrolünden geçmedi.',
    );
  }
}
