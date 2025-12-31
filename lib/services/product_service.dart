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

  static Future<ProductDetail> getProductDetail(int id) async {
    final res = await ApiClient.get('/api/Product/$id');
    return ProductDetail.fromJson(res);
  }

  // ================= SỬA ĐỔI: LẤY THÔNG TIN BIẾN THỂ (GỒM GIÁ VÀ ID) =================
  /// Thay thế hàm getPrice cũ bằng hàm này để lấy đầy đủ thông tin đặt hàng
  static Future<Map<String, dynamic>> getVariantDetails({
    required int sanPhamId,
    required int mauId,
    required int sizeId,
  }) async {
    // Gọi đến API bóc tách thông tin biến thể
    // Lưu ý: Backend cần trả về JSON dạng: {"price": 200000, "bienTheId": 45150}
    final data = await ApiClient.get(
      '/api/Product/get-price'
          '?sanPhamId=$sanPhamId&mauId=$mauId&sizeId=$sizeId',
    );

    // Trả về Map chứa cả giá và bienTheId
    return {
      'price': data['giaBan'] ?? 0,
      'bienTheId': data['bienTheId'] ?? 0,
    };
  }

  // ================= LẤY GIÁ THEO BIẾN THỂ =================
  // static Future<int> getPrice({
  //   required int sanPhamId,
  //   required int mauId,
  //   required int sizeId,
  // }) async {
  //   final data = await ApiClient.get(
  //     '/api/Product/get-price'
  //         '?sanPhamId=$sanPhamId&mauId=$mauId&sizeId=$sizeId',
  //   );
  //   return PriceResponse.fromJson(data).price;
  // }

// ================= GỢI Ý SP TƯƠNG TỰ =================
  static Future<List<ProductRecommend>> getRecommendations(int productId) async {
    final data = await ApiClient.get(
      '/api/Product/$productId/recommendations',
    );
    return (data as List)
        .map((e) => ProductRecommend.fromJson(e))
        .toList();
  }

// ================= TÌM KIẾM TỪ KHÓA =================
  static Future<List<ProductRecommend>> searchByKeyword(String keyword) async {
    final data = await ApiClient.get(
      '/api/Product/search?keyword=$keyword',
    );

    return (data as List)
        .map((e) => ProductRecommend.fromJson(e))
        .toList();
  }

}