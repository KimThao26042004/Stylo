import 'api_client.dart';
import '../models/account_profile.dart';
import '../models/account_address.dart';
import 'package:dio/dio.dart';


class AccountService {
  final ApiClient _api = ApiClient();

  /* ================= PROFILE ================= */

  /// GET /api/Account/profile
  Future<AccountProfile> getProfile() async {
    final res = await _api.dio.get("/api/Account/profile");
    return AccountProfile.fromJson(Map<String, dynamic>.from(res.data));
  }

  /// PUT /api/Account/profile
  Future<void> updateProfile(AccountProfile profile) async {
    await _api.dio.put(
      "/api/Account/profile",
      data: profile.toJson(),
    );
  }

  /* ================= AUTH / SECURITY ================= */

  /// POST /api/Account/change-password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _api.dio.post(
      "/api/Account/change-password",
      data: {
        "oldPassword": oldPassword,
        "newPassword": newPassword,
      },
    );
  }

  /* ================= ADDRESSES ================= */

  /// GET /api/Account/addresses
  Future<List<AccountAddress>> getAddresses() async {
    final res = await _api.dio.get("/api/Account/addresses");
    final List list = res.data;
    return list.map((e) => AccountAddress.fromJson(e)).toList();
  }

  /// POST /api/Account/addresses
  Future<void> addAddress({
    required String diaChiChiTiet,
    required String loaiDiaChi,
    bool isDefault = false,
  }) async {
    await _api.dio.post("/api/Account/addresses", data: {
      "diaChiID": 0,
      "diaChiChiTiet": diaChiChiTiet,
      "loaiDiaChi": loaiDiaChi,
      "isDefault": isDefault,
    });
  }

  /// PUT /api/Account/addresses/{id}/default
  Future<void> setDefaultAddress(int id) async {
    await _api.dio.put("/api/Account/addresses/$id/default");
  }

  /// DELETE /api/Account/addresses/{id}
  // Future<void> deleteAddress(int id) async {
  //   await _api.dio.delete("/api/Account/addresses/$id");
  // }
  Future<bool> deleteAddress(int id) async {
    try {
      print("Đang gọi API xóa ID: $id"); // Debug xem id có phải là 0 không
      final response = await _api.dio.delete("/api/Account/addresses/$id");

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("Lỗi xóa địa chỉ: ${e.response?.data}");
      return false;
    } catch (e) {
      print("Lỗi không xác định: $e");
      return false;
    }
  }
}
