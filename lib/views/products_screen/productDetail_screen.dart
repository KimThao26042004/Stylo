import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_detail.dart';
import '../../models/product_recommend.dart';
import '../../services/product_service.dart';
import '../../state/saved_provider.dart';
import '../../state/cart_provider.dart';
import '../../widgets/recommend_section.dart';

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

  // ===== RECOMMEND =====
  List<ProductRecommend> _recommends = [];
  bool _loadingRecommend = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
    _loadRecommend();
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

  Future<void> _loadRecommend() async {
    try {
      final data =
      await ProductService.getRecommendations(widget.productId);
      if (!mounted) return;
      setState(() => _recommends = data);
    } catch (_) {
      // ignore recommend error
    } finally {
      if (!mounted) return;
      setState(() => _loadingRecommend = false);
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
    final saved = context.watch<SavedProvider>();
    final isFavorite = saved.isSaved(p.sanPhamId);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),

      /// ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE + FAVORITE
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Image.network(
                    p.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      saved.toggle(p);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            saved.isSaved(p.sanPhamId)
                                ? 'Đã thêm vào danh sách yêu thích'
                                : 'Đã bỏ khỏi danh sách yêu thích',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            /// PRODUCT INFO
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// COLORS
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
                        int.parse('0xff${c.maHex.replaceFirst('#', '')}'),
                      );

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedMauId = c.id);
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

                  const SizedBox(height: 24),

                  /// SIZES
                  const Text(
                    'Choose size',
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
                        selectedColor: Colors.red,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  /// DESCRIPTION
                  Text(
                    p.description.isNotEmpty
                        ? p.description
                        : 'This casual T-shirt is designed for everyday comfort while maintaining a clean and modern style. Made from high-quality cotton fabric, it feels soft on the skin and allows good breathability, making it suitable for all-day wear. The regular fit provides a balanced silhouette that is neither too tight nor too loose, ensuring comfort during daily activities such as walking, studying, or meeting friends. Its short sleeves and classic round neckline create a timeless look that never goes out of fashion. The shirt is easy to mix and match with jeans, trousers, or shorts, making it a versatile piece in any wardrobe. With durable stitching and color retention after washing, this T-shirt is ideal for those who value both practicality and simple elegance in their clothing choices.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            /// ================= RECOMMEND =================
            if (_loadingRecommend)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              RecommendSection(items: _recommends),
          ],
        ),
      ),

      /// ================= BOTTOM BAR =================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${_price ?? p.basePrice} đ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (_selectedMauId == null || _selectedSizeId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng chọn màu và size')),
                  );
                  return;
                }
                final selectedSize = p.availableSizes
                    .firstWhere((e) => e.id == _selectedSizeId);

                final selectedColor = p.availableColors
                    .firstWhere((e) => e.id == _selectedMauId);
                context.read<CartProvider>().add(
                  product: p,
                  sizeId: selectedSize.id,
                  colorId: selectedColor.id,
                  sizeName: selectedSize.kyHieu,
                  colorName: selectedColor.ten,
                  price: _price!,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã thêm vào giỏ hàng')),
                );
              },

              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text(
                'Add to Cart',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
