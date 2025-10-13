import 'package:dio/dio.dart';
import '../models/order_models.dart';
import 'api_client.dart';

class OrdersApi {
  final ApiClient _client;
  OrdersApi(this._client);

  Future<List<OrderDto>> getOrders(String status) async {
    // status: "ongoing" hoặc "completed" (tuỳ backend quy ước)
    final res = await _client.dio.get('/api/orders', queryParameters: {'status': status});
    return OrdersResponse.fromJson(res.data as Map<String,dynamic>).items;
  }

  Future<TrackingDto> getTracking(String orderId) async {
    final res = await _client.dio.get('/api/orders/$orderId/tracking');
    return TrackingDto.fromJson(res.data as Map<String,dynamic>);
  }
}
