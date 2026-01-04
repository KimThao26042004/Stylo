import '../models/location_model.dart';
import 'api_client.dart';
import '../models/account_profile.dart';
import '../models/account_address.dart';
import 'package:dio/dio.dart';


class AccountService {
  final ApiClient _api = ApiClient();
  final Dio _publicDio = Dio();

  // Lấy danh sách Tỉnh/Thành
  Future<List<LocationModel>> getProvinces() async {
    final res = await _publicDio.get("https://provinces.open-api.vn/api/p/");
    return (res.data as List).map((e) => LocationModel.fromJson(e)).toList();
  }

  // Lấy Quận/Huyện theo mã Tỉnh
  Future<List<LocationModel>> getDistricts(int provinceCode) async {
    final res = await _publicDio.get("https://provinces.open-api.vn/api/p/$provinceCode?depth=2");
    final List list = res.data['districts'];
    return list.map((e) => LocationModel.fromJson(e)).toList();
  }

  // Lấy Xã/Phường theo mã Huyện
  Future<List<LocationModel>> getWards(int districtCode) async {
    final res = await _publicDio.get("https://provinces.open-api.vn/api/d/$districtCode?depth=2");
    final List list = res.data['wards'];
    return list.map((e) => LocationModel.fromJson(e)).toList();
  }

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

  Future<void> updateAddress({
    required int id,
    required String diaChiChiTiet,
    required String loaiDiaChi,
    required bool isDefault,
  }) async {
    await _api.dio.put("/api/Account/addresses/$id", data: {
      "diaChiID": id,
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