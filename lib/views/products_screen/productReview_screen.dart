import 'package:flutter/material.dart';
import '../auth_screen/auth_common.dart';
import '../../data/mock_db.dart';

class ProductReviewsScreen extends StatelessWidget {
  final MockProduct product;
  const ProductReviewsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // mock data: thay bằng API .NET khi có
    final reviews = _mockReviews;
    final avg =
        reviews.map((e) => e.rating).fold<double>(0, (a, b) => a + b) /
            reviews.length;
    final dist = _distribution(reviews); // 5..1 → count

    return Scaffold(
      appBar: const AppBackBar(title: 'Reviews'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          // header điểm & thanh phân bố
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(avg.toStringAsFixed(1),
                style:
                const TextStyle(fontSize: 48, fontWeight: FontWeight.w800)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: List.generate(5, (i) {
                  final star = 5 - i; // 5 -> 1
                  final count = dist[star] ?? 0;
                  final ratio = count / reviews.length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Row(
                            children: List.generate(
                                5,
                                    (j) => Icon(
                                  j < star
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 16,
                                  color: Colors.amber,
                                ))),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade200,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(count.toString()),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Text('${reviews.length} Ratings',
              style: const TextStyle(color: AppTheme.lightText)),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                  child: Text('45 Reviews',
                      style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
              Text('Most Relevant',
                  style: TextStyle(color: AppTheme.lightText)),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),

          // list reviews
          ...reviews.map((r) => _ReviewTile(r)).toList(),
        ],
      ),
    );
  }

  static Map<int, int> _distribution(List<_Review> rs) {
    final map = <int, int>{};
    for (final r in rs) {
      map[r.rating.round()] = (map[r.rating.round()] ?? 0) + 1;
    }
    return map;
  }
}

class _Review {
  final String user;
  final String content;
  final double rating;
  final String timeAgo; // ví dụ: "6 days ago"
  const _Review(
      {required this.user,
        required this.content,
        required this.rating,
        required this.timeAgo});
}

class _ReviewTile extends StatelessWidget {
  final _Review r;
  const _ReviewTile(this.r);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Row(
              children: List.generate(
                5,
                    (i) => Icon(
                  i < r.rating.round() ? Icons.star : Icons.star_border,
                  size: 16,
                  color: Colors.amber,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(r.user, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Text('• ${r.timeAgo}',
                style: const TextStyle(color: AppTheme.lightText)),
          ],
        ),
        const SizedBox(height: 6),
        Text(r.content),
        const SizedBox(height: 12),
        const Divider(),
      ]),
    );
  }
}

// ===== mock reviews (thay bằng API) =====
const _mockReviews = <_Review>[
  _Review(
    user: 'Wade Warren',
    content:
    'The item is very good, my son likes it very much and plays every day.',
    rating: 5,
    timeAgo: '6 days ago',
  ),
  _Review(
    user: 'Guy Hawkins',
    content:
    'The seller is very fast in sending packet, I just bought it and the item arrived in just 1 day!',
    rating: 5,
    timeAgo: '1 week ago',
  ),
  _Review(
    user: 'Robert Fox',
    content:
    'I just bought it and the stuff is really good! I highly recommend it!',
    rating: 4,
    timeAgo: '2 weeks ago',
  ),
];
