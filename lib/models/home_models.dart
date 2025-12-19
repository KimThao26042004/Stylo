import 'category.dart';
import 'product.dart';

class HomeResponse {
  final List<Category> phanLoaiList;
  final List<Product> products;

  HomeResponse({
    required this.phanLoaiList,
    required this.products,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      phanLoaiList: (json['phanLoaiList'] as List)
          .map((e) => Category.fromJson(e))
          .toList(),
      products: (json['initialVariants'] as List)
          .map((e) => Product.fromJson(e))
          .toList(),
    );
  }
}
