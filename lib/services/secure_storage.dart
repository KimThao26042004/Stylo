import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'access_token';

  // static Future<void> saveToken(String token) =>
  //     _storage.write(key: "token", value: token);

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  // static Future<String?> getToken() => _storage.read(key: "token");
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _keyToken);
  }

  static Future<void> saveKhachHangId(String id) async {
    await _storage.write(key: 'khachHangId', value: id);
  }

  static Future<String?> getKhachHangId() async {
    return await _storage.read(key: 'khachHangId');
  }
}