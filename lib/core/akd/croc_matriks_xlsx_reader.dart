import 'dart:typed_data';

import 'package:excel/excel.dart';

/// Decodes a Matriks XLSX export into the table shape consumed by the AKD parser.
class CrocMatriksXlsxReader {
  const CrocMatriksXlsxReader();

  List<List<Object?>> read(Uint8List bytes) {
    if (bytes.isEmpty) return const [];
    final workbook = Excel.decodeBytes(bytes);
    for (final name in workbook.tables.keys) {
      final sheet = workbook.tables[name];
      if (sheet == null || sheet.rows.isEmpty) continue;
      final table = sheet.rows
          .map((row) => row.map<Object?>((cell) => _value(cell?.value)).toList(growable: false))
          .toList(growable: false);
      final headerIndex = table.indexWhere(_isAkdHeader);
      if (headerIndex < 0) continue;
      return List<List<Object?>>.unmodifiable(
        table.skip(headerIndex).where((row) => row.any((cell) => cell != null && cell.toString().trim().isNotEmpty)).map(
          (row) => List<Object?>.unmodifiable(List<Object?>.generate(9, (index) => index < row.length ? row[index] : null)),
        ),
      );
    }
    return const [];
  }

  bool _isAkdHeader(List<Object?> row) {
    if (row.length < 9) return false;
    final first = (row[0] ?? '').toString().trim().toLowerCase();
    final second = (row[1] ?? '').toString().trim().toLowerCase();
    final fourth = (row[3] ?? '').toString().trim().toLowerCase();
    final eighth = (row[7] ?? '').toString().trim().toLowerCase();
    return first.contains('kurum') &&
        (second.contains('al') || second.contains('buy')) &&
        (fourth.contains('sat') || fourth.contains('sell')) &&
        eighth.contains('net');
  }

  String _text(TextSpan span) {
    final buffer = StringBuffer(span.text ?? '');
    for (final child in span.children ?? const <TextSpan>[]) {
      buffer.write(_text(child));
    }
    return buffer.toString();
  }

  Object? _value(CellValue? value) => switch (value) {
        null => null,
        TextCellValue() => _text(value.value),
        IntCellValue() => value.value,
        DoubleCellValue() => value.value,
        BoolCellValue() => value.value,
        FormulaCellValue() => value.formula,
        DateCellValue() => value.asDateTimeLocal(),
        DateTimeCellValue() => value.asDateTimeLocal(),
        TimeCellValue() => value.asDuration(),
      };
}
