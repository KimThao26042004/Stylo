import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderService {
  static Future<int> checkout({
    required String token,
    required Map<String, dynamic> payload,
  }) async {
    final res = await http.post(
      Uri.parse('https://localhost:7200/api/Order/checkout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode != 200) {
      throw Exception('Checkout failed');
    }

    final data = jsonDecode(res.body);
    return data['orderID'];
  }
}
