import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_history_model.dart';


class OrderService {
  final String baseUrl = "https://your-api-domain.com/api/Account";

  Future<List<OrderHistoryModel>> getPurchaseHistory(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/purchase-history'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => OrderHistoryModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load history');
    }
  }
}