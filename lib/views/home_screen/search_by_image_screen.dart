import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/similar_product.dart';
import '../../models/product.dart';
import '../../services/image_search_service.dart';
import '../../widgets/product_card.dart';

class SearchByImageScreen extends StatefulWidget {
  const SearchByImageScreen({super.key});

  @override
  State<SearchByImageScreen> createState() => _SearchByImageScreenState();
}

class _SearchByImageScreenState extends State<SearchByImageScreen> {
  XFile? _image;
  bool _loading = false;
  List<SimilarProduct> _results = [];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() {
      _image = picked;
    });

    await _search();
  }

  Future<void> _search() async {
    if (_image == null) return;

    setState(() => _loading = true);

    try {
      final data = await ImageSearchService.searchByImage(_image!);
      setState(() => _results = data);
    } catch (e) {
      debugPrint("SEARCH IMAGE ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Search failed: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tìm kiếm hình ảnh")),
      body: Column(
        children: [
          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: _pickImage,
            child: const Text("Chọn ảnh"),
          ),

          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),

          const SizedBox(height: 14),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _results.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.63,
              ),
              itemBuilder: (_, i) {
                final p = _results[i];

                /// convert SimilarProduct → Product (CHỈ ĐỂ HIỂN THỊ)
                final product = Product(
                  sanPhamId: p.id,
                  tenSanPham: p.name,
                  giaBan: p.price,
                  imageUrl:
                  "${ImageSearchService.imageBaseUrl}${p.imageUrl}",
                );

                return ProductCard(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }
}
