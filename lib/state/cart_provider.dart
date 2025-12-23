import 'package:flutter/material.dart';

import '../models/product_detail.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  /// ===== GETTERS =====
  List<CartItem> get items => _items;

  int get totalQuantity =>
      _items.fold(0, (sum, e) => sum + e.quantity);

  double get subTotal =>
      _items.fold(0, (sum, e) => sum + (e.price * e.quantity));

  static const double shippingFee = 30000;
  static const double vat = 0;

  double get total => subTotal + shippingFee + vat;

  /// ===== ADD TO CART =====
  void add({
    required ProductDetail product,
    required int sizeId,
    required String sizeName,
    required int colorId,
    required String colorName,
    required int price,
  }) {
    // Kiểm tra trùng sản phẩm + size + màu
    final index = _items.indexWhere(
          (e) =>
      e.product.sanPhamId == product.sanPhamId &&
          e.sizeId == sizeId &&
          e.colorId == colorId,
    );

    if (index >= 0) {
      // 👉 Trùng thì tăng số lượng
      _items[index] =
          _items[index].copyWith(quantity: _items[index].quantity + 1);
    } else {
      // 👉 Chưa có thì thêm mới
      _items.add(
        CartItem(
          product: product,
          quantity: 1,
          price: price,
          sizeId: sizeId,
          sizeName: sizeName,
          colorId: colorId,
          colorName: colorName,
        ),
      );
    }

    notifyListeners();
  }

  /// ===== UPDATE QUANTITY =====
  void increaseQty(CartItem item) {
    final index = _items.indexOf(item);
    if (index >= 0) {
      _items[index] =
          item.copyWith(quantity: item.quantity + 1);
      notifyListeners();
    }
  }

  void decreaseQty(CartItem item) {
    final index = _items.indexOf(item);
    if (index >= 0 && item.quantity > 1) {
      _items[index] =
          item.copyWith(quantity: item.quantity - 1);
      notifyListeners();
    }
  }

  /// ===== REMOVE =====
  void remove(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  /// ===== CLEAR =====
  void clear() {
    _items.clear();
    notifyListeners();
  }

  // Map<String, dynamic> toCheckoutPayload(int khachHangId) {
  //   return {
  //     'khachHangId': khachHangId,
  //     'kenhBan': 'ONLINE',
  //     'phiVanChuyen': shippingFee,
  //     'items': _items.map((e) => e.toCheckoutJson()).toList(),
  //   };
  // }
}
