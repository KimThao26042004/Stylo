import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/home_models.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  bool isLoading = false;
  bool _loadedHome = false;

  // ===== DATA =====
  List<Category> phanLoai = [];
  List<Category> danhMuc = [];
  List<Product> sanPham = [];

  int? selectedPhanLoaiId;
  int? selectedDanhMucId;

  // ================= LOAD HOME (CHỈ 1 LẦN) =================
  Future<void> loadHome() async {
    if (_loadedHome) return;

    isLoading = true;
    notifyListeners();

    try {
      final res = await ProductService.getHome();
      phanLoai = res.phanLoaiList;
      sanPham = res.products.take(50).toList(); //  10 SP HOME
      selectedPhanLoaiId = null; // ALL
      _loadedHome = true;
    } catch (e) {
      debugPrint('loadHome error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  // ================= LOAD DANH MỤC =================
  Future<void> loadDanhMuc(int phanLoaiId) async {
    isLoading = true;
    notifyListeners();

    try {
      danhMuc = await ProductService.getDanhMuc(phanLoaiId);
    } catch (e) {
      debugPrint('loadDanhMuc error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  // ================= CHỌN PHÂN LOẠI (CHIP HOME) =================
  Future<void> selectPhanLoai(int phanLoaiId) async {
    selectedPhanLoaiId = phanLoaiId;
    isLoading = true;
    notifyListeners();

    try {
      sanPham = (await ProductService.getVariantsByPhanLoai(phanLoaiId))
          .take(10)
          .toList();
    } catch (e) {
      debugPrint('selectPhanLoai error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  // ================= CHỌN DANH MỤC =================
  Future<void> selectDanhMuc(int danhMucId) async {
    isLoading = true;
    notifyListeners();

    try {
      sanPham =
          (await ProductService.getSanPhamByDanhMuc(danhMucId)).take(10).toList();
    } catch (e) {
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }


  // ================= RESET (LOGOUT / REFRESH) =================
  void reset() {
    _loadedHome = false;
    phanLoai.clear();
    danhMuc.clear();
    sanPham.clear();
    selectedPhanLoaiId = null;
    selectedDanhMucId = null;
    notifyListeners();
  }
}
