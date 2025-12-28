enum OrderStatus { created, picked, inTransit, delivered, failed, returned }

class OrderHistoryModel {
  final String id;
  final String trangThaiGiao;
  final double tongThanhToan;
  final DateTime ngayDat;
  final String? maVanDon;
  final List<OrderItemModel> items;

  OrderHistoryModel({
    required this.id,
    required this.trangThaiGiao,
    required this.tongThanhToan,
    required this.ngayDat,
    this.maVanDon,
    required this.items,
  });

  OrderStatus get statusEnum {
    // Chuyển đổi dựa trên dữ liệu thực tế từ API (CREATED, DELIVERED,...)
    switch (trangThaiGiao.toUpperCase()) {
      case 'CREATED': return OrderStatus.created;
      case 'PICKED': return OrderStatus.picked;
      case 'INTRANSIT': return OrderStatus.inTransit;
      case 'DELIVERED': return OrderStatus.delivered;
      case 'FAILED': return OrderStatus.failed;
      case 'RETURNED': return OrderStatus.returned;
      default: return OrderStatus.created;
    }
  }

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderHistoryModel(
      id: json['donHangId'].toString(),
      trangThaiGiao: json['trangThaiGiao'] ?? 'CREATED',
      tongThanhToan: (json['tongThanhToan'] as num).toDouble(),
      ngayDat: DateTime.parse(json['ngayDat']),
      maVanDon: json['maVanDon'],
      items: (json['chiTietItems'] as List)
          .map((i) => OrderItemModel.fromJson(i))
          .toList(),
    );
  }
}

class OrderItemModel {
  final int bienTheId;
  final int sanPhamId;
  final int sizeId;
  final String name;
  final String imageUrl;
  final double price;
  final String size;
  final int quantity;
  final Map<String, dynamic> mauSac;


  OrderItemModel({
    required this.bienTheId,
    required this.sanPhamId,
    required this.sizeId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.size,
    required this.quantity,
    required this.mauSac,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      bienTheId: json['bienTheId'] ?? 0,
      sanPhamId: json['sanPhamId'] ?? 0,
      sizeId: json['sizeId'] ?? 0,
      name: json['tenSanPham'] ?? 'Unknown',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['donGia'] as num).toDouble(),
      size: json['size'] ?? 'M',
      quantity: json['soLuong'] ?? 1,
      mauSac: json['mauSac'] ?? {'id': 0, 'ten': 'N/A', 'maHex': '#000000'},
    );
  }
}