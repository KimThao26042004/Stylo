import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart'; // Đã mở comment
import '../services/auth_service.dart';
import '../services/secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final AuthService _service;

  bool isLoading = false;
  String? error;

  String? userId;
  int? khachHangId;
  String? email;
  String? role;
  String? token;

  AuthProvider(this._service);

  /// Hàm bổ trợ dùng chung cho các tác vụ Auth
  /// Đã tích hợp DioException để bóc tách lỗi từ .NET Middleware
  Future<void> _run(Future<void> Function() action) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await action();

    } on DioException catch (e) {
      // 1. Xử lý lỗi trả về từ Server (400, 401, 500...)
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map) {
          // Lấy message từ JSON mà ExceptionMiddleware trả về
          error = data['message'] ?? data['Message'] ?? "Yêu cầu thất bại";
        } else {
          error = "Lỗi hệ thống: ${e.response?.statusCode}";
        }
      }
      // 2. Xử lý lỗi kết nối hạ tầng
      else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        error = "Kết nối quá hạn, vui lòng kiểm tra mạng";
      } else {
        error = "Không thể kết nối tới máy chủ";
      }
    } catch (e) {
      // 3. Các lỗi logic khác
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String fullName, String email, String password) =>
      _run(() async {
        await _auth.register(fullName: fullName, email: email, password: password);
        this.email = email;
      });

  Future<void> resendOtp(String email) =>
      _run(() async => _auth.resendOtp(email));

  Future<void> forgotPassword(String email) =>
      _run(() async {
        await _auth.forgotPassword(email);
        this.email = email;
      });

  Future<void> resetPassword(String email, String newPassword) =>
      _run(() async => _auth.resetPassword(email: email, newPassword: newPassword));

  Future<void> logout() =>
      _run(() async {
        await SecureStorage.clearToken();
        token = null;
        role = null;
        email = null;
        userId = null;
        khachHangId = null;
      });

  // --- CÁC HÀM CẦN XỬ LÝ RIÊNG BIỆT ---

  Future<void> login(String email, String password) async {
    // Sử dụng lại _run để bóc tách lỗi Dio cho Login
    await _run(() async {
      final res = await _service.login(email: email, password: password);
      final tokenValue = res['token'];
      final tkIdValue = res['taiKhoanId']?.toString();
      final khIdValue = res['khachHangId']; // Lấy ID khách hàng kiểu int

      if (tokenValue == null) throw Exception('Token not found');

      await SecureStorage.saveToken(tokenValue);
      token = tokenValue;
      userId = tkIdValue;
      khachHangId = khIdValue is int ? khIdValue : int.tryParse(khIdValue.toString());
      this.email = email;
      this.role = res['role'];
    });
  }

  Future<void> verifyOtp({required String email, required String code}) async {
    // Sử dụng lại _run thay vì viết Try-Catch riêng để đồng bộ tin nhắn lỗi
    await _run(() async {
      await _service.verifyOtp(email: email, code: code);
    });
  }

  Future<void> verifyResetOtp({required String email, required String code}) async {
    // Sử dụng lại _run để đồng bộ
    await _run(() async {
      await _service.verifyResetOtp(email: email, code: code);
    });
  }

  /// Xóa lỗi cũ khi người dùng chuyển trang hoặc bắt đầu thao tác mới
  void clearError() {
    error = null;
    notifyListeners();
  }
}