class SimilarProduct {
  final int id;
  final String name;
  final int price;
  final String imageUrl;

  SimilarProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  factory SimilarProduct.fromJson(Map<String, dynamic> json) {
    return SimilarProduct(
      id: json['SanPhamID'],
      name: json['TenSanPham'],
      price: json['GiaBan'],
      imageUrl: json['UrlAnh'],
    );
  }
}
