// import 'package:dio/dio.dart';
//
// class ApiClient {
//   static const String baseUrl = 'https://your-dotnet-host.com'; // TODO: đổi
//   final Dio dio;
//
//   ApiClient._(this.dio);
//
//   factory ApiClient({String? token}) {
//     final dio = Dio(BaseOptions(
//       baseUrl: baseUrl,
//       connectTimeout: const Duration(seconds: 12),
//       receiveTimeout: const Duration(seconds: 12),
//       headers: {
//         'Accept': 'application/json',
//         if (token != null) 'Authorization': 'Bearer $token',
//       },
//     ));
//     dio.interceptors.add(LogInterceptor(
//         requestBody: true, responseBody: true, requestHeader: false, responseHeader: false));
//     return ApiClient._(dio);
//   }
//
// }
import 'package:dio/dio.dart';
import 'api_config.dart';
import 'secure_storage.dart';

class ApiClient {
  //  lấy baseUrl theo môi trường
  static String get baseUrl => ApiConfig.baseUrl;

  final Dio dio;

  ApiClient._(this.dio);

  factory ApiClient({String? token}) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ));

    //  Tự gắn token cho mọi request (nếu chưa truyền token)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final hasAuth = options.headers.containsKey('Authorization');
          if (!hasAuth) {
            final t = await SecureStorage.getToken();
            if (t != null && t.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $t';
            }
          }
          handler.next(options);
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: false,
      responseHeader: false,
    ));

    return ApiClient._(dio);
  }
}
