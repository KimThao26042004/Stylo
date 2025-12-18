import 'package:flutter/material.dart';

class ListProductsScreen extends StatelessWidget {
  final String subCategoryName;

  const ListProductsScreen({
    super.key,
    required this.subCategoryName,
  });

  final List<Map<String, dynamic>> products = const [
    {
      'id': 1,
      'name': 'Áo thun basic',
      'price': 199000,
    },
    {
      'id': 2,
      'name': 'Áo thun form rộng',
      'price': 249000,
    },
    {
      'id': 3,
      'name': 'Áo thun cotton',
      'price': 299000,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(subCategoryName)),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final p = products[index];
          return Card(
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.image, size: 50),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    p['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${p['price']} đ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
