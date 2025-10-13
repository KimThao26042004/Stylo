import 'package:flutter/foundation.dart';
import '../data/mock_db.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore._();
  static final FavoritesStore instance = FavoritesStore._();

  final Set<int> _ids = {}; // lưu id sản phẩm yêu thích

  bool isSaved(int productId) => _ids.contains(productId);

  void toggle(int productId) {
    if (_ids.contains(productId)) {
      _ids.remove(productId);
    } else {
      _ids.add(productId);
    }
    notifyListeners();
  }

  List<MockProduct> get items =>
      MockDb.products.where((p) => _ids.contains(p.id)).toList();

  int get count => _ids.length;

  void clear() {
    _ids.clear();
    notifyListeners();
  }
}
