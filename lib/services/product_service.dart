import '../models/category.dart';
import '../models/product.dart';
import '../models/home_models.dart';
import '../models/product_detail.dart';
import '../models/price_response.dart';
import '../models/product_recommend.dart';
import 'api_client.dart';

class ProductService {
  // ================= HOME =================
  static Future<HomeResponse> getHome() async {
    final res = await ApiClient.get('/api/Product/home');
    return HomeResponse.fromJson(res);
  }

  // ================= PHÂN LOẠI =================
  static Future<List<Category>> getPhanLoai() async {
    final data = await ApiClient.get('/api/Product/phan-loai');
    return (data as List)
        .map((e) => Category.fromJson(e))
        .toList();
  }

  // ================= DANH MỤC THEO PHÂN LOẠI =================
  static Future<List<Category>> getDanhMuc(int phanLoaiId) async {
    final res =
    await ApiClient.get('/api/Product/phan-loai/$phanLoaiId/danh-muc');
    return (res as List).map((e) => Category.fromJson(e)).toList();
  }

  // ================= SẢN PHẨM THEO DANH MỤC =================
  static Future<List<Product>> getSanPhamByDanhMuc(int danhMucId) async {
    final res =
    await ApiClient.get('/api/Product/danh-muc/$danhMucId/san-pham');
    return (res as List).map((e) => Product.fromJson(e)).toList();
  }

  // ================= SẢN PHẨM THEO PHÂN LOẠI (HOME CHIP) =================
  static Future<List<Product>> getVariantsByPhanLoai(int phanLoaiId) async {
    final data = await ApiClient.get(
      '/api/Product/variants/by-phanloai/$phanLoaiId',
    );

    return (data as List)
        .map((e) => Product.fromJson(e))
        .toList();
  }


  // ================= CHI TIẾT SẢN PHẨM =================
  // static Future<ProductDetail> getProductDetail(int sanPhamId) async {
  //   final data = await ApiClient.get('/api/Product/$sanPhamId');
  //   return ProductDetail.fromJson(data);
  // }
  static Future<ProductDetail> getProductDetail(int id) async {
    final res = await ApiClient.get('/api/Product/$id');
    return ProductDetail.fromJson(res);
  }

  // ================= LẤY GIÁ THEO BIẾN THỂ =================
  static Future<int> getPrice({
    required int sanPhamId,
    required int mauId,
    required int sizeId,
  }) async {
    final data = await ApiClient.get(
      '/api/Product/get-price'
          '?sanPhamId=$sanPhamId&mauId=$mauId&sizeId=$sizeId',
    );
    return PriceResponse.fromJson(data).price;
  }

// ================= GỢI Ý SP TƯƠNG TỰ =================
  static Future<List<ProductRecommend>> getRecommendations(int productId) async {
    final data = await ApiClient.get(
      '/api/Product/$productId/recommendations',
    );
    return (data as List)
        .map((e) => ProductRecommend.fromJson(e))
        .toList();
  }
}
