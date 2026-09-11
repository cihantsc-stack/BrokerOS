import 'app_failure.dart';

sealed class AppResult<T> {
  const AppResult();

  bool get isSuccess => this is AppSuccess<T>;
  bool get isFailure => this is AppError<T>;

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppFailure failure) onFailure,
  }) {
    final AppResult<T> self = this;

    if (self is AppSuccess<T>) {
      return onSuccess(self.data);
    }

    return onFailure((self as AppError<T>).failure);
  }
}

final class AppSuccess<T> extends AppResult<T> {
  final T data;

  const AppSuccess(this.data);
}

final class AppError<T> extends AppResult<T> {
  final AppFailure failure;

  const AppError(this.failure);
}
