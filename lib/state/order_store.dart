import 'package:flutter/foundation.dart';
import '../models/order_models.dart';
import '../services/order_api.dart';
import '../services/api_client.dart';

class OrdersStore extends ChangeNotifier {
  final OrdersApi api;
  OrdersStore({String? token}) : api = OrdersApi(ApiClient(token: token));

  bool loadingOngoing = false;
  bool loadingCompleted = false;
  Object? errorOngoing;
  Object? errorCompleted;

  List<OrderDto> ongoing = [];
  List<OrderDto> completed = [];

  Future<void> loadOngoing() async {
    loadingOngoing = true; errorOngoing = null; notifyListeners();
    try {
      ongoing = await api.getOrders('ongoing');
    } catch (e) {
      errorOngoing = e;
    } finally {
      loadingOngoing = false; notifyListeners();
    }
  }

  Future<void> loadCompleted() async {
    loadingCompleted = true; errorCompleted = null; notifyListeners();
    try {
      completed = await api.getOrders('completed');
    } catch (e) {
      errorCompleted = e;
    } finally {
      loadingCompleted = false; notifyListeners();
    }
  }
}
