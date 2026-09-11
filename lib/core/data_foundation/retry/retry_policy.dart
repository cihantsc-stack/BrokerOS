import '../logger/app_logger.dart';

class RetryPolicy {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffMultiplier;

  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 250),
    this.backoffMultiplier = 1.8,
  });

  Future<T> execute<T>(
    Future<T> Function() operation, {
    bool Function(Object error)? shouldRetry,
  }) async {
    Object? lastError;
    Duration delay = initialDelay;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await operation();
      } catch (error) {
        lastError = error;

        final bool retryAllowed = shouldRetry?.call(error) ?? true;

        if (!retryAllowed || attempt == maxAttempts) {
          rethrow;
        }

        AppLogger.instance.warning(
          'İşlem başarısız. Yeniden deneme: '
          '$attempt/$maxAttempts',
        );

        await Future<void>.delayed(delay);

        delay = Duration(
          milliseconds: (delay.inMilliseconds * backoffMultiplier).round(),
        );
      }
    }

    throw StateError('Retry işlemi tamamlanamadı: $lastError');
  }
}
