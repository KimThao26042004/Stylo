import 'package:flutter/material.dart';
import '../auth_screen/auth_common.dart';
import '../../models/product_recommend.dart';
import '../../services/product_service.dart';
import 'search_by_image_screen.dart';
import '../../widgets/product_card.dart';
import '../../models/product.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  bool _loading = false;
  List<ProductRecommend> _results = [];

  final List<String> _recent = [
    'Jeans',
    'Casual clothes',
    'Hoodie',
    'Nike shoes',
    'V-neck tshirt',
    'Winter clothes',
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final text = _controller.text;
      if (text != _query) {
        setState(() => _query = text);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitSearch(String text) async {
    final key = text.trim();
    if (key.isEmpty) return;

    setState(() {
      _loading = true;
      _query = key;
    });

    try {
      final data = await ProductService.searchByKeyword(key);
      setState(() => _results = data);
    } catch (e) {
      debugPrint('SEARCH ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Search failed')),
      );
    } finally {
      setState(() => _loading = false);
    }

    setState(() {
      _recent.removeWhere((e) => e.toLowerCase() == key.toLowerCase());
      _recent.insert(0, key);
      if (_recent.length > 10) _recent.removeLast();
    });
  }

  void _clearAll() => setState(() => _recent.clear());

  void _openSearchByImage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchByImageScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showRecent = _query.trim().isEmpty;

    return Scaffold(
      appBar: const AppBackBar(title: 'Tìm kiếm'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Column(
          children: [
            /// SEARCH BOX
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: _submitSearch,
              decoration: AppTheme.input(
                '',
                hint: 'Tìm kiếm...',
              ).copyWith(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_a_photo_outlined),
                  onPressed: _openSearchByImage,
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// BODY
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : showRecent
                  ? _RecentList(
                items: _recent,
                onTap: (kw) {
                  _controller.text = kw;
                  _controller.selection =
                      TextSelection.collapsed(offset: kw.length);
                  _submitSearch(kw);
                },
                onRemove: (kw) =>
                    setState(() => _recent.remove(kw)),
                onClearAll: _clearAll,
              )
                  : (_results.isEmpty
                  ? const _EmptyResult()
                  : _ResultGrid(results: _results)),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= RECENT LIST ================= */

class _RecentList extends StatelessWidget {
  final List<String> items;
  final void Function(String keyword) onTap;
  final void Function(String keyword) onRemove;
  final VoidCallback onClearAll;

  const _RecentList({
    required this.items,
    required this.onTap,
    required this.onRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Row(
          children: [
            const Text(
              'Tìm kiếm gần đây',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            if (items.isNotEmpty)
              TextButton(
                onPressed: onClearAll,
                child: const Text('Xóa lịch sử tìm kiếm'),
              ),
          ],
        ),
        const SizedBox(height: 6),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              'Không có tìm kiếm gần đây',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...items.map(
                (kw) => ListTile(
              dense: true,
              title: Text(kw),
              trailing: IconButton(
                onPressed: () => onRemove(kw),
                icon: const Icon(Icons.close, size: 18),
              ),
              onTap: () => onTap(kw),
            ),
          ),
      ],
    );
  }
}

/* ================= RESULT GRID ================ */
class _ResultGrid extends StatelessWidget {
  final List<ProductRecommend> results;
  const _ResultGrid({required this.results});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.63, // giống Home
      ),
      itemCount: results.length,
      itemBuilder: (context, i) {
        final product = _toProduct(results[i]);
        return ProductCard(product: product);
      },
    );
  }
}

/* ================= EMPTY ================= */

class _EmptyResult extends StatelessWidget {
  const _EmptyResult();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.search, size: 56, color: AppTheme.lightText),
          SizedBox(height: 12),
          Text(
            'Không tìm thấy kết quả nào!',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          SizedBox(height: 6),
          Text(
            'Hãy thử một từ tương tự hoặc một từ nào đó mang tính khái quát hơn.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.lightText),
          ),
        ],
      ),
    );
  }
}

Product _toProduct(ProductRecommend r) {
  return Product(
    sanPhamId: r.sanPhamId,
    tenSanPham: r.tenSanPham,
    giaBan: r.giaBan,
    imageUrl: r.imageUrl,
  );
}
