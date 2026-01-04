import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/product_recommend.dart';

class RecommendCard extends StatelessWidget {
  final ProductRecommend product;
  const RecommendCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final priceFormat = NumberFormat("#,##0", "vi_VN");

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product-detail',
          arguments: product.sanPhamId,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== IMAGE (GIỐNG PRODUCT CARD) =====
            AspectRatio(
              aspectRatio: 1 / 1.25,
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image),
                ),
              ),
            ),

            // ===== CONTENT =====
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
