class ApiConfig {
  // Nếu chạy Flutter Web: localhost ok.
  // Nếu chạy Android emulator: dùng http://10.0.2.2:7200
  // Nếu chạy điện thoại thật: dùng IP máy chạy API (vd: http://192.168.1.10:7200)

  static const String baseUrl = "https://localhost:7200";
}
