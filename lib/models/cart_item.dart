import 'product_detail.dart';

class CartItem {
  final ProductDetail product;
  final int bienTheId;
  final int quantity;
  final double price; // Chuyển sang double để đồng bộ tính toán
  final int sizeId;
  final int colorId;
  final String sizeName;
  final String colorName;

  CartItem({
    required this.product,
    required this.bienTheId,
    required this.quantity,
    required this.price,
    required this.sizeId,
    required this.colorId,
    required this.sizeName,
    required this.colorName,
  });

  // Cập nhật copyWith linh hoạt hơn
  CartItem copyWith({
    ProductDetail? product,
    int? bienTheId,
    int? quantity,
    double? price,
    int? sizeId,
    int? colorId,
    String? sizeName,
    String? colorName,
  }) {
    return CartItem(
      product: product ?? this.product,
      bienTheId: bienTheId ?? this.bienTheId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      sizeId: sizeId ?? this.sizeId,
      colorId: colorId ?? this.colorId,
      sizeName: sizeName ?? this.sizeName,
      colorName: colorName ?? this.colorName,
    );
  }

  // Hàm này giúp CartProvider.processOrder sạch sẽ hơn
  Map<String, dynamic> toCheckoutJson() {
    return {
      "bienTheId": bienTheId,
      "soLuong": quantity,
      "donGia": price,
    };
  }
}