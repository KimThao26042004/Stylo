import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) =>
      _storage.write(key: "token", value: token);

  static Future<String?> getToken() => _storage.read(key: "token");

  static Future<void> clearToken() => _storage.delete(key: "token");
}
