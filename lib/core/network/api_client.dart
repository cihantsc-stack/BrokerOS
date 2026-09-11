import 'api_response.dart';

abstract interface class ApiClient {
  Future<ApiResponse<Map<String, Object?>>> get(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  });

  Future<ApiResponse<Map<String, Object?>>> post(
    String path, {
    Map<String, Object?>? body,
    Map<String, String>? headers,
  });
}

class MockApiClient implements ApiClient {
  const MockApiClient();

  @override
  Future<ApiResponse<Map<String, Object?>>> get(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));

    return ApiResponse.success<Map<String, Object?>>(<String, Object?>{
      'path': path,
      'query': queryParameters ?? const <String, String>{},
      'receivedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<ApiResponse<Map<String, Object?>>> post(
    String path, {
    Map<String, Object?>? body,
    Map<String, String>? headers,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));

    return ApiResponse.success<Map<String, Object?>>(<String, Object?>{
      'path': path,
      'body': body ?? const <String, Object?>{},
      'receivedAt': DateTime.now().toIso8601String(),
    }, statusCode: 201);
  }
}
