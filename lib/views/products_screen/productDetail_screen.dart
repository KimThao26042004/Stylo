import 'package:flutter/material.dart';
import '../../models/product_detail.dart';
import '../../services/product_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _loading = true;
  String? _error;

  ProductDetail? _product;
  int? _selectedMauId;
  int? _selectedSizeId;
  int? _price;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final res = await ProductService.getProductDetail(widget.productId);
      if (!mounted) return;

      setState(() {
        _product = res;
        _price = res.basePrice;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  /// CHỈ GỌI KHI ĐÃ CHỌN ĐỦ MÀU + SIZE
  Future<void> _updatePriceIfReady() async {
    if (_selectedMauId == null || _selectedSizeId == null) {
      setState(() => _price = _product!.basePrice);
      return;
    }

    try {
      final price = await ProductService.getPrice(
        sanPhamId: widget.productId,
        mauId: _selectedMauId!,
        sizeId: _selectedSizeId!,
      );

      if (!mounted) return;
      setState(() => _price = price);
    } catch (_) {
      // fallback
      if (!mounted) return;
      setState(() => _price = _product!.basePrice);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error!)),
      );
    }

    final p = _product!;

    return Scaffold(
      appBar: AppBar(title: Text(p.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Image.network(
                p.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Center(child: Icon(Icons.broken_image)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// NAME
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// PRICE
                  Text(
                    '${_price ?? p.basePrice} đ',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ===== COLORS  =====
                  const Text(
                    'Màu sắc',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 10,
                    children: p.availableColors.map((c) {
                      final selected = _selectedMauId == c.id;
                      final color = Color(
                        int.parse(
                          '0xff${c.maHex.replaceFirst('#', '')}',
                        ),
                      );

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMauId = c.id;
                          });
                          _updatePriceIfReady();
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: Border.all(
                              width: selected ? 3 : 1,
                              color: selected
                                  ? Colors.red
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  /// ===== SIZES =====
                  const Text(
                    'Kích thước',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    children: p.availableSizes.map((s) {
                      final selected = _selectedSizeId == s.id;

                      return ChoiceChip(
                        label: Text(s.kyHieu),
                        selected: selected,
                        onSelected: (_) {
                          setState(() => _selectedSizeId = s.id);
                          _updatePriceIfReady();
                        },
                        selectedColor: Colors.red.withOpacity(0.15),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.red : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  /// DESCRIPTION
                  Text(
                    p.description.isNotEmpty
                        ? p.description
                        : 'Mô tả sản phẩm đang được cập nhật.',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
