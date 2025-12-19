class ProductDetail {
  final int sanPhamId;
  final String name;
  final String description;
  final int basePrice;
  final String imageUrl;
  final List<MauSac> availableColors;
  final List<SizeSP> availableSizes;

  ProductDetail({
    required this.sanPhamId,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.imageUrl,
    required this.availableColors,
    required this.availableSizes,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      sanPhamId: json['sanPhamId'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      basePrice: json['basePrice'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      availableColors: (json['availableColors'] as List? ?? [])
          .map((e) => MauSac.fromJson(e))
          .toList(),
      availableSizes: (json['availableSizes'] as List? ?? [])
          .map((e) => SizeSP.fromJson(e))
          .toList(),
    );
  }
}

class MauSac {
  final int id;
  final String ten;
  final String maHex;

  MauSac({
    required this.id,
    required this.ten,
    required this.maHex,
  });

  factory MauSac.fromJson(Map<String, dynamic> json) {
    return MauSac(
      id: json['id'],
      ten: json['ten'] ?? '',
      maHex: json['maHex'] ?? '#000000',
    );
  }
}

class SizeSP {
  final int id;
  final String kyHieu;

  SizeSP({
    required this.id,
    required this.kyHieu,
  });

  factory SizeSP.fromJson(Map<String, dynamic> json) {
    return SizeSP(
      id: json['id'],
      kyHieu: json['kyHieu'] ?? '',
    );
  }
}
