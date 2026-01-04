import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For formatting price

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
  int? _currentVariantId;
  int _quantity = 1;  // Default quantity is 1

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
      final data = await ProductService.getRecommendations(widget.productId);
      if (!mounted) return;
      setState(() => _recommends = data);
    } catch (_) {
      // ignore recommend error
    } finally {
      if (!mounted) return;
      setState(() => _loadingRecommend = false);
    }
  }

  Future<void> _updatePriceIfReady() async {
    if (_product == null) return;

    if (_selectedMauId == null || _selectedSizeId == null) {
      setState(() => _price = _product?.basePrice ?? 0);
      return;
    }

    try {
      final result = await ProductService.getVariantDetails(
        sanPhamId: widget.productId,
        mauId: _selectedMauId!,
        sizeId: _selectedSizeId!,
      );

      if (!mounted) return;

      setState(() {
        _price = result['price'];
        _currentVariantId = result['bienTheId'];
      });
    } catch (e) {
      print("Lỗi lấy giá/biến thể: $e");
      if (!mounted) return;
      setState(() => _price = _product?.basePrice ?? 0);
    }
  }

  void _showCustomToast(String message, {bool isError = false, IconData? icon}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon ?? (isError ? Icons.error_outline : Icons.check_circle_outline),
              color: Colors.white,
              size: 22, // Kích thước icon vừa phải
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
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

    final priceFormat = NumberFormat("#,##0", "vi_VN");  // Format price with thousands separator

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chi tiết sản phẩm',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              final cartCount = cart.itemCount; // Get the total number of items in the cart
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                    if (cartCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$cartCount',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  // Navigate to the CartScreen when clicked
                  Navigator.pushNamed(context, '/cart');
                },
              );
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
                      final isNowSaved = saved.isSaved(p.sanPhamId);
                      _showCustomToast(
                        isNowSaved ? 'Đã thêm vào danh sách yêu thích' : 'Đã xóa khỏi danh sách yêu thích',
                        icon: isNowSaved ? Icons.favorite : Icons.favorite_border,
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
                  const SizedBox(height: 8),

                  // Moved price below the product name
                  Text(
                    '${priceFormat.format(_price ?? p.basePrice)} đ',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// COLORS
                  const Text(
                    'Chọn màu sắc',
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
                    'Chọn kích cỡ',
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
                        : 'This casual T-shirt is designed for everyday comfort...',
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
            // Quantity selection
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (_quantity > 1) {
                      setState(() => _quantity--);
                    }
                  },
                ),
                Text(
                  '$_quantity',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_quantity < 5) {  // Limit quantity to 10
                      setState(() => _quantity++);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(width: 10),  // Spacing between quantity and total price

            // Total price display (formatted)
            Text(
              'Tổng: ${NumberFormat('#,##0', 'vi_VN').format((_price ?? p.basePrice) * _quantity)} đ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(width: 10),  // Spacing between total price and Add to Cart button

            // Add to Cart button
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
                  _showCustomToast('Vui lòng chọn đầy đủ màu sắc và kích cỡ', isError: true);
                  return;
                }
                final selectedSize = p.availableSizes
                    .firstWhere((e) => e.id == _selectedSizeId);

                final selectedColor = p.availableColors
                    .firstWhere((e) => e.id == _selectedMauId);
                context.read<CartProvider>().add(
                  product: p,
                  bienTheId: _currentVariantId!,
                  sizeId: selectedSize.id,
                  colorId: selectedColor.id,
                  sizeName: selectedSize.kyHieu,
                  colorName: selectedColor.ten,
                  price: _price!,
                  quantity: _quantity,
                );
                _showCustomToast(
                  'Sản phẩm đã được thêm vào giỏ hàng',
                  icon: Icons.add_shopping_cart,
                );
              },

              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text(
                'Thêm vào giỏ hàng',
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
