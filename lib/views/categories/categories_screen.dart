import 'package:flutter/material.dart';
import 'subcategories_screen.dart';

class CategoriesScreen extends StatelessWidget {
  static const routeName = '/categories';

  const CategoriesScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {
      'id': 1,
      'name': 'Áo',
      'subCategories': [
        {'id': 11, 'name': 'Áo thun'},
        {'id': 12, 'name': 'Áo sơ mi'},
        {'id': 13, 'name': 'Áo khoác'},
      ]
    },
    {
      'id': 2,
      'name': 'Quần',
      'subCategories': [
        {'id': 21, 'name': 'Quần jean'},
        {'id': 22, 'name': 'Quần tây'},
      ]
    },
    {
      'id': 3,
      'name': 'Phụ kiện',
      'subCategories': [
        {'id': 31, 'name': 'Thắt lưng'},
        {'id': 32, 'name': 'Ví'},
      ]
    },
    {
      'id': 4,
      'name': 'Giá tốt',
      'subCategories': [
        {'id': 41, 'name': 'Sale 30%'},
        {'id': 42, 'name': 'Sale 50%'},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh mục')),
      body: ListView.separated(
        itemCount: categories.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final cate = categories[index];
          return ListTile(
            title: Text(
              cate['name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(Icons.add),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubCategoriesScreen(
                    categoryName: cate['name'],
                    subCategories: cate['subCategories'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
