import 'package:flutter/material.dart';
import '../auth_screen/auth_common.dart';
import '../../data/mock_db.dart';
import '../../state/favoritesStore.dart';
import '../../state/cartStore.dart';
import 'productReview_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final MockProduct product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? _size = 'M'; // default
  final fav = FavoritesStore.instance;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final saved = fav.isSaved(p.id);

    return Scaffold(
      appBar: const AppBackBar(title: 'Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image + heart
          Stack(children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(p.imageUrl, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Material(
                color: Colors.white,
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => fav.toggle(p.id)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      saved ? Icons.favorite : Icons.favorite_border,
                      color: saved ? Colors.red : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),

          Text(p.name,
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),

          // rating (giả lập 4.0/5 & 45 reviews) + mở Reviews
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductReviewsScreen(product: p),
                    ),
                  );
                },
                child: const Text('4.0/5 (45 reviews)',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            'The name says it all, the right size slightly snugs the body leaving enough room for comfort in the sleeves and waist.',
            style: const TextStyle(color: AppTheme.lightText),
          ),
          const SizedBox(height: 16),

          const Text('Choose size',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(spacing: 10, children: ['S', 'M', 'L'].map((s) {
            final selected = _size == s;
            return ChoiceChip(
              label: Text(s),
              selected: selected,
              onSelected: (_) => setState(() => _size = s),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            );
          }).toList()),
          const SizedBox(height: 16),

          // Price + Add to cart
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Price',
                        style: TextStyle(color: AppTheme.lightText)),
                    Text('\$ ${p.price.toInt()}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              Expanded(
                child: ElevatedButton.icon(
                  style: AppTheme.primaryButton(context),
                  onPressed: () {
                    CartStore.instance.add(p, size: _size ?? 'M');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to cart')),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to Cart'),
                ),
              ),
            ],
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {},
        backgroundColor: Colors.red,
        child: const Icon(Icons.chat),
      ),
    );
  }
}
