import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Đảm bảo đã import Dio
import '../services/account_service.dart';
import '../models/account_profile.dart';
import '../models/account_address.dart';

class AccountProvider extends ChangeNotifier {
  final AccountService _service = AccountService();

  AccountProfile? profile;
  List<AccountAddress> addresses = [];

  String? _token;
  int? _userId;

  String? get token => _token;
  int? get userId => _userId;

  bool isLoading = false;
  String? error;

  /// Hàm bổ trợ dùng chung để xử lý Loading và DioException
  /// Tự động bóc tách tin nhắn từ Backend .NET
  Future<T?> _run<T>(Future<T> Function() action) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      return await action();
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        // Trong AccountProvider -> hàm _run
        if (data is Map) {
          // Ưu tiên lấy 'error' chi tiết từ backend nếu có, nếu không thì lấy 'message'
          error = data['error'] ?? data['message'] ?? data['Message'] ?? "Yêu cầu thất bại";
        }else {
          error = "Lỗi hệ thống: ${e.response?.statusCode}";
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        error = "Kết nối quá hạn, vui lòng kiểm tra mạng";
      } else {
        error = "Không thể kết nối tới máy chủ";
      }
      return null;
    } catch (e) {
      error = "Đã xảy ra lỗi không xác định";
      debugPrint("AccountProvider Error: $e");
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setAuth({required String token, required int userId}) {
    _token = token;
    _userId = userId;
    notifyListeners();
  }

  // --- CÁC HÀM ĐÃ ĐƯỢC TỐI ƯU HÓA ---

  Future<void> loadProfile() async {
    final res = await _run(() => _service.getProfile());
    if (res != null) profile = res;
  }

  Future<void> updateProfile(AccountProfile p) async {
    await _run(() async {
      await _service.updateProfile(p);
      profile = await _service.getProfile();
    });
  }

  Future<bool> changePassword(String oldPass, String newPass) async {
    // Lưu ý: Chúng ta cần kết quả bool nên xử lý hơi khác một chút hoặc kiểm tra biến error
    await _run(() => _service.changePassword(oldPassword: oldPass, newPassword: newPass));
    return error == null;
  }

  Future<void> loadAddresses() async {
    final res = await _run(() => _service.getAddresses());
    if (res != null) addresses = res;
  }

  Future<void> addAddress({
    required String diaChiChiTiet,
    required String loaiDiaChi,
    bool isDefault = false,
  }) async {
    await _run(() async {
      await _service.addAddress(
        diaChiChiTiet: diaChiChiTiet,
        loaiDiaChi: loaiDiaChi,
        isDefault: isDefault,
      );
      addresses = await _service.getAddresses();
    });
  }

  Future<void> setDefaultAddress(int id) async {
    await _run(() async {
      await _service.setDefaultAddress(id);
      // Gọi trực tiếp _service để tránh lồng loading
      addresses = await _service.getAddresses();
    });
  }

  Future<void> deleteAddress(int id) async {
    await _run(() async {
      await _service.deleteAddress(id);
      addresses = await _service.getAddresses();
    });
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}