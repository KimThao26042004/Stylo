import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/product_detail.dart';
import '../views/products_screen/productDetail_screen.dart';
import '../state/saved_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat("#,##0", "en_US");

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProductDetailScreen(productId: product.sanPhamId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== IMAGE (fixed ratio) =====
            AspectRatio(
              aspectRatio: 1 / 1.25,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // HEART ICON
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<SavedProvider>(
                      builder: (_, savedProvider, __) {
                        final isSaved =
                        savedProvider.isSaved(product.sanPhamId);

                        return GestureDetector(
                          onTap: () {
                            savedProvider.toggle(toDetail(product));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isSaved ? Colors.red : Colors.grey,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ===== CONTENT (CỐ ĐỊNH – KHÔNG OVERFLOW) =====
            SizedBox(
              height: 76, // tổng chiều cao content
              child: Column(
                children: [
                  // NAME – LUÔN CAO BẰNG NHAU
                  SizedBox(
                    height: 36, // đủ cho 2 dòng
                    child: Text(
                      product.tenSanPham,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // PRICE – CỐ ĐỊNH
                  SizedBox(
                    height: 20,
                    child: Center(
                      child: Text(
                        '${priceFormat.format(product.giaBan)} đ',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
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
ProductDetail toDetail(Product p) {
  return ProductDetail(
    sanPhamId: p.sanPhamId,
    name: p.tenSanPham,
    description: '',
    basePrice: p.giaBan,
    availableSizes: [],
    availableColors: [],
    imageUrl: p.imageUrl,
  );
}
