import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = 'https://your-dotnet-host.com'; // TODO: đổi
  final Dio dio;

  ApiClient._(this.dio);

  factory ApiClient({String? token}) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ));
    dio.interceptors.add(LogInterceptor(
        requestBody: true, responseBody: true, requestHeader: false, responseHeader: false));
    return ApiClient._(dio);
  }
}
