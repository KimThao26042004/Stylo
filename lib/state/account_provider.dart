import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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

  /// Gọi sau khi login
  void setAuth({
    required String token,
    required int userId,
  }) {
    _token = token;
    _userId = userId;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      profile = await _service.getProfile();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(AccountProfile p) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _service.updateProfile(p);
      profile = await _service.getProfile();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(String oldPass, String newPass) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _service.changePassword(oldPassword: oldPass, newPassword: newPass);
      return true;
    } on DioException catch (e) {
      // Lấy thông báo lỗi từ server trả về (ví dụ: "Mật khẩu cũ không chính xác")
      if (e.response?.data != null && e.response?.data is Map) {
        error = e.response?.data['message'] ?? "Đã xảy ra lỗi";
      } else {
        error = "Lỗi kết nối server";
      }
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAddresses() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      addresses = await _service.getAddresses();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress({
    required String diaChiChiTiet,
    required String loaiDiaChi,
    bool isDefault = false,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _service.addAddress(
        diaChiChiTiet: diaChiChiTiet,
        loaiDiaChi: loaiDiaChi,
        isDefault: isDefault,
      );

      addresses = await _service.getAddresses();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setDefaultAddress(int id) async {
    try {
      isLoading = true;
      notifyListeners();

      await _service.setDefaultAddress(id);
      await loadAddresses();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAddress(int id) async {
    await _service.deleteAddress(id);
    await loadAddresses();
  }
}
