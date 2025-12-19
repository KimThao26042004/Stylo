class Product {
  final int sanPhamId;
  final String tenSanPham;
  final String imageUrl;
  final int giaBan;
  final int? danhMucId;

  Product({
    required this.sanPhamId,
    required this.tenSanPham,
    required this.imageUrl,
    required this.giaBan,
    this.danhMucId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      sanPhamId: json['sanPhamId'],
      tenSanPham: json['tenSanPham'],
      imageUrl: json['imageUrl'],
      giaBan: json['giaBan'] ?? 0,
      danhMucId: json['danhMucId'],
    );
  }
}
