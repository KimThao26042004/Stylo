// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItemDto _$OrderItemDtoFromJson(Map<String, dynamic> json) => OrderItemDto(
  productId: (json['productId'] as num).toInt(),
  name: json['name'] as String,
  imageUrl: json['imageUrl'] as String,
  price: (json['price'] as num).toDouble(),
  qty: (json['qty'] as num).toInt(),
);

Map<String, dynamic> _$OrderItemDtoToJson(OrderItemDto instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'price': instance.price,
      'qty': instance.qty,
    };

OrderDto _$OrderDtoFromJson(Map<String, dynamic> json) => OrderDto(
  id: json['id'] as String,
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  courier: json['courier'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OrderDtoToJson(OrderDto instance) => <String, dynamic>{
  'id': instance.id,
  'status': _$OrderStatusEnumMap[instance.status]!,
  'courier': instance.courier,
  'createdAt': instance.createdAt.toIso8601String(),
  'items': instance.items,
};

const _$OrderStatusEnumMap = {
  OrderStatus.Packing: 'Packing',
  OrderStatus.Picked: 'Picked',
  OrderStatus.InTransit: 'InTransit',
  OrderStatus.Delivered: 'Delivered',
};

OrdersResponse _$OrdersResponseFromJson(Map<String, dynamic> json) =>
    OrdersResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrdersResponseToJson(OrdersResponse instance) =>
    <String, dynamic>{'items': instance.items};

CourierDto _$CourierDtoFromJson(Map<String, dynamic> json) =>
    CourierDto(name: json['name'] as String, phone: json['phone'] as String?);

Map<String, dynamic> _$CourierDtoToJson(CourierDto instance) =>
    <String, dynamic>{'name': instance.name, 'phone': instance.phone};

TrackingDto _$TrackingDtoFromJson(Map<String, dynamic> json) => TrackingDto(
  polyline: (json['polyline'] as List<dynamic>)
      .map(
        (e) => (e as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
      )
      .toList(),
  status: $enumDecode(_$OrderStatusEnumMap, json['status']),
  courier: json['courier'] == null
      ? null
      : CourierDto.fromJson(json['courier'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TrackingDtoToJson(TrackingDto instance) =>
    <String, dynamic>{
      'polyline': instance.polyline,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'courier': instance.courier,
    };
