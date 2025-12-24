import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/secure_storage.dart';
// import 'package:dio/dio.dart';


class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();

  bool isLoading = false;
  String? error;

  String? email;
  String? role;
  String? token;

  final AuthService _service;
  AuthProvider(this._service);

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String fullName, String email, String password) =>
      _run(() async {
        await _auth.register(fullName: fullName, email: email, password: password);
        this.email = email; // lưu lại để sang màn OTP
      });

  Future<void> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      isLoading = true;
      notifyListeners();
      await _service.verifyOtp(email: email, code: code);
      error = null;
    } catch (e) {
      error = 'Xác thực thất bại';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendOtp(String email) =>
      _run(() async => _auth.resendOtp(email));

  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final res = await _service.login(
        email: email,
        password: password,
      );

      final token = res['token'];
      if (token == null) throw Exception('Token not found');

      await SecureStorage.saveToken(token);

    } on DioException catch (e) {
      // TÁI SỬ DỤNG LOGIC BẮT LỖI TỪ MIDDLEWARE .NET
      if (e.response != null && e.response?.data is Map) {
        // Lấy câu "Sai email hoặc mật khẩu" từ Backend gửi về
        error = e.response?.data['message'] ?? "Đăng nhập thất bại";
      } else {
        error = "Lỗi kết nối server hoặc sai thông tin đăng nhập";
      }
    } catch (e) {
      // Bắt các lỗi logic khác (ví dụ: lỗi lưu SecureStorage)
      error = "Đã xảy ra lỗi: ${e.toString()}";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<void> forgotPassword(String email) =>
      _run(() async {
        await _auth.forgotPassword(email);
        this.email = email;
      });

  Future<void> verifyResetOtp({
    required String email,
    required String code,
  }) async {
    try {
      isLoading = true;
      notifyListeners();
      await _service.verifyResetOtp(email: email, code: code);
      error = null;
    } catch (e) {
      error = 'Xác thực thất bại';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email, String newPassword) =>
      _run(() async => _auth.resetPassword(email: email, newPassword: newPassword));

  Future<void> logout() =>
      _run(() async {
        await SecureStorage.clearToken();
        token = null;
        role = null;
        email = null;
      });
}
