import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/similar_product.dart';
import '../../services/image_search_service.dart';

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
      _image = picked; // KHÔNG convert sang File
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
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search by Image")),
      body: Column(
        children: [
          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: _pickImage,
            child: const Text("Choose Image"),
          ),

          if (_loading) const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _results.length,
              itemBuilder: (context, i) {
                final p = _results[i];

                return GestureDetector(
                  onTap: () {
                    // 👉 sang ProductDetail
                    Navigator.pushNamed(
                      context,
                      '/product-detail',
                      arguments: p.id,
                    );
                  },
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Image.network(
                            "${ImageSearchService.imageBaseUrl}${p.imageUrl}",
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            p.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "${p.price} ₫",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
