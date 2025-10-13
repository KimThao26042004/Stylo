import 'package:flutter/material.dart';
import '../auth_screen/auth_common.dart';
import '../../data/mock_db.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  // demo recent (có thể thay bằng SharedPreferences sau)
  final List<String> _recent = [
    'Jeans',
    'Casual clothes',
    'Hoodie',
    'Nike shoes black',
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

  void _submitSearch(String text) {
    final key = text.trim();
    if (key.isEmpty) return;
    // thêm vào recent (không trùng, đưa lên đầu)
    setState(() {
      _recent.removeWhere((e) => e.toLowerCase() == key.toLowerCase());
      _recent.insert(0, key);
      if (_recent.length > 10) _recent.removeLast();
      _query = key;
      _controller.text = key;
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    });
  }

  void _clearAll() => setState(() => _recent.clear());

  @override
  Widget build(BuildContext context) {
    final results = MockDb.products
        .where((p) => p.name.toLowerCase().contains(_query.toLowerCase().trim()))
        .toList();

    final showRecent = _query.trim().isEmpty;

    return Scaffold(
      appBar: const AppBackBar(title: 'Search'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: _submitSearch,
              decoration: AppTheme.input('', hint: 'Search for clothes...').copyWith(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _submitSearch(_controller.text),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: showRecent
                  ? _RecentList(
                items: _recent,
                onTap: (kw) {
                  _controller.text = kw;
                  _submitSearch(kw);
                },
                onRemove: (kw) => setState(() => _recent.remove(kw)),
                onClearAll: _clearAll,
              )
                  : (results.isEmpty
                  ? const _EmptyResult()
                  : _ResultList(results: results)),
            ),
          ],
        ),
      ),
    );
  }
}

/* ============== Recent Section ============== */
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
            const Text('Recent Searches',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            if (items.isNotEmpty)
              TextButton(onPressed: onClearAll, child: const Text('Clear all')),
          ],
        ),
        const SizedBox(height: 6),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text(
              'No recent searches',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...items.map((kw) => ListTile(
            dense: true,
            title: Text(kw),
            trailing: IconButton(
              onPressed: () => onRemove(kw),
              icon: const Icon(Icons.close, size: 18),
            ),
            onTap: () => onTap(kw),
          )),
      ],
    );
  }
}

/* ============== Result List ============== */
class _ResultList extends StatelessWidget {
  final List<MockProduct> results;
  const _ResultList({required this.results});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final p = results[i];
        final hasDiscount = p.discountPercent != null;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(p.imageUrl, width: 52, height: 52, fit: BoxFit.cover),
          ),
          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Row(
            children: [
              Text('\$ ${p.price.toInt()}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              if (hasDiscount) ...[
                const SizedBox(width: 6),
                Text('\$ ${(p.price * 1.3).toInt()}',
                    style: TextStyle(
                        color: Colors.grey[500],
                        decoration: TextDecoration.lineThrough)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.red.withOpacity(.08),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    '-${p.discountPercent}%',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
          trailing: const Icon(Icons.north_east, size: 18),
          onTap: () {
            // TODO: mở trang chi tiết sản phẩm
          },
        );
      },
    );
  }
}

/* ============== Empty-state khi không có kết quả ============== */
class _EmptyResult extends StatelessWidget {
  const _EmptyResult();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
        Icon(Icons.search, size: 56, color: AppTheme.lightText),
        SizedBox(height: 12),
        Text('No Results Found!',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        SizedBox(height: 6),
        Text('Try a similar word or something\nmore general.',
            textAlign: TextAlign.center, style: TextStyle(color: AppTheme.lightText)),
      ]),
    );
  }
}
