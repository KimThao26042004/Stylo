enum OrderStatus { packing, picked, inTransit, delivered }

class OrderHistoryModel {
  final String id;
  final String trangThai;
  final double tongThanhToan;
  final DateTime ngayDat;
  final String? maVanDon;
  final List<OrderItemModel> items;

  OrderHistoryModel({
    required this.id,
    required this.trangThai,
    required this.tongThanhToan,
    required this.ngayDat,
    this.maVanDon,
    required this.items,
  });

  // Chuyển đổi trạng thái từ chuỗi DB sang Enum Flutter
  OrderStatus get statusEnum {
    switch (trangThai.toLowerCase()) {
      case 'packing': return OrderStatus.packing;
      case 'shipping': return OrderStatus.inTransit;
      case 'delivered': return OrderStatus.delivered;
      default: return OrderStatus.picked;
    }
  }

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderHistoryModel(
      id: json['donHangId'].toString(),
      trangThai: json['trangThai'] ?? 'Picked',
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
  final String name;
  final String imageUrl;
  final double price;
  final String size;
  final int quantity;

  OrderItemModel({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.size,
    required this.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      name: json['tenSanPham'] ?? 'Unknown',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['donGia'] as num).toDouble(),
      size: json['size'] ?? 'M',
      quantity: json['soLuong'] ?? 1,
    );
  }
}