class ProductRecommend {
  final int sanPhamId;
  final String tenSanPham;
  final int giaBan;
  final String imageUrl;

  ProductRecommend({
    required this.sanPhamId,
    required this.tenSanPham,
    required this.giaBan,
    required this.imageUrl,
  });

  factory ProductRecommend.fromJson(Map<String, dynamic> json) {
    return ProductRecommend(
      sanPhamId: json['sanPhamId'],
      tenSanPham: json['tenSanPham'],
      giaBan: json['giaBan'],
      imageUrl: json['imageUrl'],
    );
  }
}
