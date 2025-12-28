import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/order_history_model.dart';

class OrderProvider extends ChangeNotifier {
  // 1. CHỈ để đường dẫn gốc (Root). Lưu ý: Nếu dùng máy ảo Android, hãy thay localhost thành 10.0.2.2
  // Nếu dùng Flutter Web, đảm bảo .NET API đã cấu hình CORS.
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "https://localhost:7200/api/",
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  List<OrderHistoryModel> _orders = [];
  bool _isLoading = false;
  String? error;

  bool get isLoading => _isLoading;
  List<OrderHistoryModel> get allOrders => _orders;

  List<OrderHistoryModel> get ongoingOrders =>
      _orders.where((o) => o.statusEnum != OrderStatus.delivered).toList();

  List<OrderHistoryModel> get completedOrders =>
      _orders.where((o) => o.statusEnum == OrderStatus.delivered).toList();

  Future<void> fetchOrders(String token) async {
    try {
      _isLoading = true;
      error = null;
      notifyListeners();

      // 2. Gọi đúng Action trong AccountController
      final response = await _dio.get(
        "Account/purchase-history", // Không thêm 'api/' vì đã có ở baseUrl
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
      );

      if (response.statusCode == 200) {
        // 3. Xử lý dữ liệu an toàn
        if (response.data is List) {
          final List data = response.data;
          _orders = data.map((json) => OrderHistoryModel.fromJson(json)).toList();
        } else {
          _orders = [];
        }
      }
    } on DioException catch (e) {
      // Bắt lỗi 404, 401, 500 từ Server
      final dynamic responseData = e.response?.data;
      if (responseData is Map && responseData.containsKey('message')) {
        error = responseData['message'].toString();
      } else {
        error = "Lỗi kết nối Server: ${e.response?.statusCode ?? e.type}";
      }
      debugPrint("Lỗi API Chi Tiết: ${e.response?.data}");
    } catch (e) {
      error = "Lỗi xử lý dữ liệu (Có thể do Model sai kiểu dữ liệu)";
      debugPrint("Lỗi Logic: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}