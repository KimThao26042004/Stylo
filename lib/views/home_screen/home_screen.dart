import 'package:flutter/material.dart';
import '../auth_screen/auth_common.dart';
import 'notifications_screen.dart';
import 'search_screen.dart';
import '../../data/mock_db.dart';
import '../../state/favoritesStore.dart';
import '../savedItems_screen/saved_screen.dart';
import '../cart_screen/cart_screen.dart';
import '../profile_screen/account_screen.dart';
import '../customerService_screen/customerService_screen.dart';
import '../products_screen/productDetail_screen.dart';
import '../categories/categories_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  int? _selectedCatId; // null = All

  void _openNotifications() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
  }

  void _openSearch() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
  }

  void _openCategories() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
  }

  void _openSaved() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SavedScreen()));
  }

  void _openCart() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  void _openAccount() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AccountScreen()));
  }

  void _openCustomerService() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerServiceScreen()));
  }

  void _onBottomTap(int i) {
    setState(() => _tabIndex = i);
    switch (i) {
      case 0: break;               // Home
      case 1: _openCategories(); break;
      case 2: _openSaved();  break;
      case 3: _openCart();   break;
      case 4: _openAccount();break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = MockDb.products
        .where((p) => _selectedCatId == null || p.categoryId == _selectedCatId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stylo', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(onPressed: _openNotifications, icon: const Icon(Icons.notifications_none)),
        ],
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            GestureDetector(
              onTap: _openSearch,
              child: AbsorbPointer(
                child: TextField(
                  decoration: AppTheme.input('', hint: 'Search for clothes...').copyWith(
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(onPressed: _openSearch, icon: const Icon(Icons.tune)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: MockDb.categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final isAll = i == 0;
                  final selected = isAll ? _selectedCatId == null : _selectedCatId == MockDb.categories[i - 1].id;
                  final label = isAll ? 'All' : MockDb.categories[i - 1].chipLabel;
                  final catId = isAll ? null : MockDb.categories[i - 1].id;
                  return ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCatId = catId),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            AnimatedBuilder(
              animation: FavoritesStore.instance,
              builder: (_, __) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .66,
                  ),
                  itemBuilder: (_, i) => _ProductCard(p: products[i]),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: _onBottomTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _openCustomerService,
        backgroundColor: Colors.red,
        child: const Icon(Icons.chat),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final MockProduct p;
  const _ProductCard({required this.p});

  @override
  Widget build(BuildContext context) {
    final store = FavoritesStore.instance;
    final saved = store.isSaved(p.id);
    final hasDiscount = p.discountPercent != null;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
              child: AspectRatio(aspectRatio: 1, child: Image.network(p.imageUrl, fit: BoxFit.cover)),
            ),
            Positioned(
              right: 8, top: 8,
              child: CircleAvatar(
                radius: 16, backgroundColor: Colors.white,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(saved ? Icons.favorite : Icons.favorite_border,
                      size: 18, color: saved ? Colors.red : Colors.black87),
                  onPressed: () => store.toggle(p.id),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(children: [
              Text('\$ ${p.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.w700)),
              if (hasDiscount) ...[
                const SizedBox(width: 6),
                Text('\$ ${(p.price * 1.3).toInt()}',
                    style: TextStyle(color: Colors.grey[500], decoration: TextDecoration.lineThrough)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(.08), borderRadius: BorderRadius.circular(8)),
                  child: Text('-${p.discountPercent}%',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                )
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}
