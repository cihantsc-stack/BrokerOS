class AppLogger {
  AppLogger._();

  static final AppLogger instance = AppLogger._();

  final List<String> _records = <String>[];

  List<String> get records => List<String>.unmodifiable(_records);

  void info(String message) {
    _write('INFO', message);
  }

  void warning(String message) {
    _write('WARN', message);
  }

  void error(String message, [Object? error]) {
    _write('ERROR', error == null ? message : '$message | $error');
  }

  void clear() {
    _records.clear();
  }

  void _write(String level, String message) {
    final String line = '${DateTime.now().toIso8601String()} [$level] $message';
    _records.add(line);

    if (_records.length > 200) {
      _records.removeAt(0);
    }
  }
}
