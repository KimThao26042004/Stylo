// lib/data/mock_db.dart
class MockCategory {
  final int id;
  final String name;
  final String chipLabel; // label tiếng Anh ngắn cho chip
  MockCategory({required this.id, required this.name, required this.chipLabel});
}

class MockProduct {
  final int id;
  final String name;
  final int categoryId;
  final double price;
  final String imageUrl;
  final int? discountPercent;
  MockProduct({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.imageUrl,
    this.discountPercent,
  });
}

class MockDb {
  // Map danh mục theo SQL: Áo thun (Tshirts), Quần jean (Jeans), Giày sneaker (Shoes)
  // id là giả lập cho UI filter
  static final categories = <MockCategory>[
    MockCategory(id: 1, name: 'Áo thun', chipLabel: 'Tshirts'),
    MockCategory(id: 2, name: 'Quần jean', chipLabel: 'Jeans'),
    MockCategory(id: 3, name: 'Giày sneaker', chipLabel: 'Shoes'),
  ];

  // Sản phẩm mẫu theo tên trong SQL
  static final products = <MockProduct>[
    MockProduct(
      id: 101,
      name: 'Áo thun basic premium',
      categoryId: 1,
      price: 199000,
      imageUrl: 'https://picsum.photos/seed/ts1/600/800',
      discountPercent: null,
    ),
    MockProduct(
      id: 102,
      name: 'Áo thun oversized',
      categoryId: 1,
      price: 199000,
      imageUrl: 'https://picsum.photos/seed/ts2/600/800',
      discountPercent: 25,
    ),
    MockProduct(
      id: 201,
      name: 'Quần jean tapered',
      categoryId: 2,
      price: 299000,
      imageUrl: 'https://picsum.photos/seed/je1/600/800',
      discountPercent: null,
    ),
    MockProduct(
      id: 202,
      name: 'Quần jean regular',
      categoryId: 2,
      price: 299000,
      imageUrl: 'https://picsum.photos/seed/je2/600/800',
      discountPercent: null,
    ),
    MockProduct(
      id: 301,
      name: 'Sneaker classic',
      categoryId: 3,
      price: 699000,
      imageUrl: 'https://picsum.photos/seed/sn1/600/800',
      discountPercent: null,
    ),
  ];
}
