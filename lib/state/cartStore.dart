import 'package:flutter/foundation.dart';
import '../data/mock_db.dart';

class CartStore extends ChangeNotifier {
  CartStore._();
  static final CartStore instance = CartStore._();

  // productId -> {qty, size}
  final Map<int, _Line> _lines = {};

  void add(MockProduct p, {String size = 'M', int qty = 1}) {
    final cur = _lines[p.id];
    if (cur == null) {
      _lines[p.id] = _Line(product: p, qty: qty, size: size);
    } else {
      _lines[p.id] = cur.copyWith(qty: cur.qty + qty, size: size);
    }
    notifyListeners();
  }

  void inc(int productId) {
    final cur = _lines[productId];
    if (cur == null) return;
    _lines[productId] = cur.copyWith(qty: cur.qty + 1);
    notifyListeners();
  }

  void dec(int productId) {
    final cur = _lines[productId];
    if (cur == null) return;
    final q = (cur.qty - 1).clamp(1, 999);
    _lines[productId] = cur.copyWith(qty: q);
    notifyListeners();
  }

  void remove(int productId) {
    _lines.remove(productId);
    notifyListeners();
  }

  List<_Line> get items => _lines.values.toList();

  double get subTotal =>
      _lines.values.fold(0.0, (a, b) => a + b.product.price * b.qty);
}

class _Line {
  final MockProduct product;
  final int qty;
  final String size;
  const _Line({required this.product, required this.qty, required this.size});

  _Line copyWith({MockProduct? product, int? qty, String? size}) =>
      _Line(product: product ?? this.product, qty: qty ?? this.qty, size: size ?? this.size);
}
