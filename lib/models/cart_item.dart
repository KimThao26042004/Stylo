import 'product_detail.dart';

class CartItem {
  final ProductDetail product;

  final int quantity;
  final int price;

  final int sizeId;
  final int colorId;

  // 👉 THÊM 2 FIELD NÀY
  final String sizeName;   // ví dụ: "L"
  final String colorName;  // ví dụ: "Black"

  CartItem({
    required this.product,
    required this.quantity,
    required this.price,
    required this.sizeId,
    required this.colorId,
    required this.sizeName,
    required this.colorName,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      price: price,
      sizeId: sizeId,
      colorId: colorId,
      sizeName: sizeName,
      colorName: colorName,
    );
  }
}
