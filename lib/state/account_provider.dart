import 'package:flutter/material.dart';
import '../services/account_service.dart';
import '../models/account_profile.dart';
import '../models/account_address.dart';

class AccountProvider extends ChangeNotifier {
  final AccountService _service = AccountService();

  AccountProfile? profile;
  List<AccountAddress> addresses = [];

  bool isLoading = false;
  String? error;

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
