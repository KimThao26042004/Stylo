// import 'order_history_model.dart'; // Để dùng enum OrderStatus
//
// class OrderViewModel {
//   final String id;
//   final OrderStatus status;
//   final DateTime ngayDat;
//   final double tongThanhToan;
//   final List<OrderItemViewModel> items;
//
//   OrderViewModel({
//     required this.id,
//     required this.status,
//     required this.ngayDat,
//     required this.tongThanhToan,
//     required this.items,
//   });
//
//   factory OrderViewModel.fromJson(Map<String, dynamic> json) {
//     // Map string từ DB .NET sang Enum Flutter
//     OrderStatus getStatus(String? st) {
//       switch (st?.toLowerCase()) {
//         case 'packing': return OrderStatus.packing;
//         case 'shipping': return OrderStatus.inTransit;
//         case 'delivered': return OrderStatus.delivered;
//         default: return OrderStatus.picked;
//       }
//     }
//
//     return OrderViewModel(
//       id: json['donHangId'].toString(),
//       status: getStatus(json['trangThai']),
//       ngayDat: DateTime.parse(json['ngayDat']),
//       tongThanhToan: (json['tongThanhToan'] as num).toDouble(),
//       items: (json['chiTietItems'] as List)
//           .map((i) => OrderItemViewModel.fromJson(i))
//           .toList(),
//     );
//   }
// }
//
// class OrderItemViewModel {
//   final String name;
//   final String imageUrl;
//   final double price;
//   final String size;
//
//   OrderItemViewModel({
//     required this.name,
//     required this.imageUrl,
//     required this.price,
//     required this.size,
//   });
//
//   factory OrderItemViewModel.fromJson(Map<String, dynamic> json) {
//     return OrderItemViewModel(
//       name: json['tenSanPham'] ?? 'Sản phẩm',
//       imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
//       price: (json['donGia'] as num).toDouble(),
//       size: json['size'] ?? 'M',
//     );
//   }
// }