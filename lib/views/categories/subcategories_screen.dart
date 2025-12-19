import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/product_service.dart';
import 'list_products_screen.dart';

class SubCategoriesScreen extends StatefulWidget {
  final int phanLoaiId;
  final String phanLoaiName;

  const SubCategoriesScreen({
    super.key,
    required this.phanLoaiId,
    required this.phanLoaiName,
  });

  @override
  State<SubCategoriesScreen> createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen> {
  bool _loading = true;
  String? _error;
  List<Category> _danhMuc = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await ProductService.getDanhMuc(widget.phanLoaiId);
      if (!mounted) return;
      setState(() {
        _danhMuc = list;
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
      appBar: AppBar(title: Text(widget.phanLoaiName)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : ListView.separated(
        itemCount: _danhMuc.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final dm = _danhMuc[i];
          return ListTile(
            title: Text(dm.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListProductsScreen(
                    danhMucId: dm.id,
                    danhMucName: dm.name,
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
