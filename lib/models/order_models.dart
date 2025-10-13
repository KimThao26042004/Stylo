import 'package:json_annotation/json_annotation.dart';
part 'order_models.g.dart';

// Nếu server trả "Packing","Picked","InTransit","Delivered" dạng chuỗi:
enum OrderStatus { Packing, Picked, InTransit, Delivered }

@JsonSerializable()
class OrderItemDto {
  final int productId;
  final String name;
  final String imageUrl;
  final double price;
  final int qty;

  OrderItemDto({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.qty,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) =>
      _$OrderItemDtoFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemDtoToJson(this);
}

@JsonSerializable()
class OrderDto {
  final String id;
  final OrderStatus status;
  final String? courier;
  final DateTime createdAt;
  final List<OrderItemDto> items;

  OrderDto({
    required this.id,
    required this.status,
    this.courier,
    required this.createdAt,
    required this.items,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) =>
      _$OrderDtoFromJson(json);
  Map<String, dynamic> toJson() => _$OrderDtoToJson(this);

  double get subTotal => items.fold(0.0, (a, b) => a + b.price * b.qty);
}

@JsonSerializable()
class OrdersResponse {
  final List<OrderDto> items;
  OrdersResponse({required this.items});

  factory OrdersResponse.fromJson(Map<String, dynamic> json) =>
      _$OrdersResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrdersResponseToJson(this);
}

@JsonSerializable()
class CourierDto {
  final String name;
  final String? phone;
  CourierDto({required this.name, this.phone});

  factory CourierDto.fromJson(Map<String, dynamic> json) =>
      _$CourierDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CourierDtoToJson(this);
}

@JsonSerializable()
class TrackingDto {
  // danh sách [lng,lat]
  final List<List<double>> polyline;
  final OrderStatus status;
  final CourierDto? courier;

  TrackingDto({
    required this.polyline,
    required this.status,
    this.courier,
  });

  factory TrackingDto.fromJson(Map<String, dynamic> json) =>
      _$TrackingDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TrackingDtoToJson(this);
}
