import '../exceptions/app_exception.dart';
import '../logger/app_logger.dart';
import '../result/app_failure.dart';
import '../result/app_result.dart';

abstract class BaseRepository {
  Future<AppResult<T>> guard<T>(Future<T> Function() operation) async {
    try {
      final T value = await operation();
      return AppSuccess<T>(value);
    } on AppException catch (error) {
      AppLogger.instance.error(error.message, error);

      return AppError<T>(
        AppFailure(
          code: error.code,
          message: error.message,
          cause: error.cause,
        ),
      );
    } catch (error) {
      AppLogger.instance.error('Beklenmeyen repository hatası.', error);

      return AppError<T>(
        AppFailure(
          code: 'unexpected_error',
          message: 'Beklenmeyen bir veri hatası oluştu.',
          cause: error,
        ),
      );
    }
  }
}
