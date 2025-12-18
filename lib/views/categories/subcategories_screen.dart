import 'package:flutter/material.dart';
import 'list_products_screen.dart';

class SubCategoriesScreen extends StatelessWidget {
  final String categoryName;
  final List<Map<String, dynamic>> subCategories;

  const SubCategoriesScreen({
    super.key,
    required this.categoryName,
    required this.subCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: ListView.separated(
        itemCount: subCategories.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final sub = subCategories[index];
          return ListTile(
            title: Text(sub['name']),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListProductsScreen(
                    subCategoryName: sub['name'],
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
