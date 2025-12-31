import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product_detail.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // Getter for item count
  int get itemCount => _items.fold(0, (sum, e) => sum + e.quantity); // Get total quantity of items

  double get subTotal => _items.fold(0, (sum, e) => sum + (e.price * e.quantity));

  static const double shippingFee = 30000;
  static const double vat = 0;

  double get total => subTotal + shippingFee + vat;

  /// ===== ADD TO CART =====
  void add({
    required ProductDetail product,
    required int bienTheId,
    required int sizeId,
    required String sizeName,
    required int colorId,
    required String colorName,
    required int price,
  }) {
    // Check if the product already exists in the cart
    final index = _items.indexWhere((e) => e.bienTheId == bienTheId);

    if (index >= 0) {
      // If exists, increase the quantity
      _items[index] = _items[index].copyWith(quantity: _items[index].quantity + 1);
    } else {
      // Otherwise, add a new item to the cart
      _items.add(
        CartItem(
          product: product,
          bienTheId: bienTheId,
          quantity: 1,
          price: price.toDouble(),
          sizeId: sizeId,
          sizeName: sizeName,
          colorId: colorId,
          colorName: colorName,
        ),
      );
    }
    notifyListeners();
  }

  void addFromReorder({
    required int bienTheId,
    required int sanPhamId,
    required int sizeId,
    required String sizeName,
    required int colorId,
    required String colorName,
    required String productName,
    required String imageUrl,
    required int price,
  }) {
    final index = _items.indexWhere((e) => e.bienTheId == bienTheId);

    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: _items[index].quantity + 1);
    } else {
      final minimalProduct = ProductDetail(
        sanPhamId: sanPhamId,
        name: productName,
        description: "",
        basePrice: price,
        imageUrl: imageUrl,
        availableColors: [],
        availableSizes: [],
      );

      _items.add(
        CartItem(
          product: minimalProduct,
          bienTheId: bienTheId,
          quantity: 1,
          price: price.toDouble(),
          sizeId: sizeId,
          sizeName: sizeName,
          colorId: colorId,
          colorName: colorName,
        ),
      );
    }
    notifyListeners();
  }

  void increaseQty(CartItem item) {
    final index = _items.indexOf(item);
    if (index >= 0) {
      _items[index] = item.copyWith(quantity: item.quantity + 1);
      notifyListeners();
    }
  }

  void decreaseQty(CartItem item) {
    final index = _items.indexOf(item);
    if (index >= 0 && item.quantity > 1) {
      _items[index] = item.copyWith(quantity: item.quantity - 1);
      notifyListeners();
    }
  }

  void remove(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  Future<int?> processOrder({
    required int khachHangId,
    required double shippingFee,
  }) async {
    _isProcessing = true;
    notifyListeners();

    final url = Uri.parse("https://localhost:7200/api/Order/checkout");

    try {
      if (khachHangId <= 0) throw Exception("Dữ liệu khách hàng không hợp lệ.");

      final body = {
        "khachHangId": khachHangId,
        "kenhBan": "APP_MOBILE",
        "phiVanChuyen": shippingFee,
        "items": _items.map((item) => {
          "bienTheId": item.bienTheId,
          "soLuong": item.quantity,
          "donGia": item.price.toDouble(),
        }).toList(),
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        clear();
        return data['orderID'];
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? errorData['detail'] ?? "Lỗi đặt hàng");
      }
    } catch (e) {
      print("Log lỗi Checkout: $e");
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
