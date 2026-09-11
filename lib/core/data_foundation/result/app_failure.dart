class AppFailure {
  final String code;
  final String message;
  final Object? cause;

  const AppFailure({required this.code, required this.message, this.cause});

  @override
  String toString() => 'AppFailure($code): $message';
}
