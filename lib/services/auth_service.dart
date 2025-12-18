import 'api_client.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _api.dio.post("/api/auth/register", data: {
      "fullName": fullName,
      "email": email,
      "password": password,
    });
  }

  Future<void> verifyOtp({
    required String email,
    required String code,
  }) async {
    await _api.dio.post("/api/auth/verify-otp", data: {
      "email": email,
      "code": code,
    });
  }

  Future<void> resendOtp(String email) async {
    await _api.dio.post("/api/auth/resend-otp", data: email);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.dio.post("/api/auth/login", data: {
      "email": email,      // TenDangNhap
      "password": password // MatKhau
    });
    return Map<String, dynamic>.from(res.data);
  }

  Future<void> forgotPassword(String email) async {
    await _api.dio.post(
      "/api/auth/forgot-password",
      data: email,
    );
  }


  Future<void> verifyResetOtp({
    required String email,
    required String code,
  }) async {
    await _api.dio.post(
      "/api/auth/verify-reset-otp",
      data: {
        "email": email,
        "code": code,
      },
    );
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await _api.dio.post("/api/auth/resend-otp", data: email);
  }
}
