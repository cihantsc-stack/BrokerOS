class ApiResponse<T> {
  final T? data;
  final int statusCode;
  final String? message;
  final bool fromCache;

  const ApiResponse({
    required this.data,
    required this.statusCode,
    this.message,
    this.fromCache = false,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300 && data != null;

  static ApiResponse<T> success<T>(
    T data, {
    int statusCode = 200,
    bool fromCache = false,
  }) {
    return ApiResponse<T>(
      data: data,
      statusCode: statusCode,
      fromCache: fromCache,
    );
  }

  static ApiResponse<T> failure<T>(String message, {int statusCode = 500}) {
    return ApiResponse<T>(data: null, statusCode: statusCode, message: message);
  }
}
