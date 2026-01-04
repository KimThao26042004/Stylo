import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../widgets/product_card.dart';
import '../products_screen/productDetail_screen.dart';

class ListProductsScreen extends StatefulWidget {
  final int danhMucId;
  final String danhMucName;

  const ListProductsScreen({
    super.key,
    required this.danhMucId,
    required this.danhMucName,
  });

  @override
  State<ListProductsScreen> createState() => _ListProductsScreenState();
}

class _ListProductsScreenState extends State<ListProductsScreen> {
  bool _loading = true;
  String? _error;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list =
      await ProductService.getSanPhamByDanhMuc(widget.danhMucId);
      if (!mounted) return;
      setState(() {
        _products = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.danhMucName)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _products.length,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.63,
        ),
        itemBuilder: (_, i) {
          return ProductCard(product: _products[i]);
        },
      ),
    );
  }
}
