import 'package:flutter/material.dart';
import '../models/product_detail.dart';

class SavedProvider extends ChangeNotifier {
  final List<ProductDetail> _savedItems = [];

  List<ProductDetail> get items => _savedItems;

  bool isSaved(int productId) {
    return _savedItems.any((p) => p.sanPhamId == productId);
  }

  void toggle(ProductDetail product) {
    if (isSaved(product.sanPhamId)) {
      _savedItems.removeWhere((p) => p.sanPhamId == product.sanPhamId);
    } else {
      _savedItems.add(product);
    }
    notifyListeners();
  }
}
