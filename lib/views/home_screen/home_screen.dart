import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth_screen/auth_common.dart';
import 'notifications_screen.dart';
import 'search_screen.dart';

import '../../state/product_provider.dart';
import '../../models/product.dart';
import '../../models/category.dart';

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

  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => context.read<ProductProvider>().loadHome(),
    );
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  void _openCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CategoriesScreen()),
    );
  }

  void _openSaved() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SavedScreen()),
    );
  }

  void _openCart() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  void _openAccount() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AccountScreen()),
    );
  }

  void _openCustomerService() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomerServiceScreen()),
    );
  }

  void _onBottomTap(int i) {
    setState(() => _tabIndex = i);
    switch (i) {
      case 0:
        break;
      case 1:
        _openCategories();
        break;
      case 2:
        _openSaved();
        break;
      case 3:
        _openCart();
        break;
      case 4:
        _openAccount();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    final products = provider.sanPham;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stylo',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _openNotifications,
            icon: const Icon(Icons.notifications_none),
          ),
        ],
        scrolledUnderElevation: 0,
      ),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            /// ===== SEARCH =====
            GestureDetector(
              onTap: _openSearch,
              child: AbsorbPointer(
                child: TextField(
                  decoration: AppTheme.input(
                    '',
                    hint: 'Search for clothes...',
                  ).copyWith(
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: _openSearch,
                      icon: const Icon(Icons.tune),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: provider.phanLoai.length + 1, // +1 cho ALL
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {

                  /// ===== ALL =====
                  if (index == 0) {
                    return ChoiceChip(
                      label: const Text('All'),
                      selected: provider.selectedPhanLoaiId == null,
                      onSelected: (_) {
                        provider.loadHome(); //gọi API HOME
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }

                  /// ===== PHÂN LOẠI =====
                  final pl = provider.phanLoai[index - 1];
                  final selected = provider.selectedPhanLoaiId == pl.id;

                  return ChoiceChip(
                    label: Text(pl.name),
                    selected: selected,
                    onSelected: (_) {
                      provider.selectPhanLoai(pl.id); // API by-phanloai
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            /// ===== GRID SẢN PHẨM (10 SP) =====
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: .66,
              ),
              itemBuilder: (_, i) =>
                  _ProductCard(p: products[i]),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),

      /// ===== BOTTOM NAV =====
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: _onBottomTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: 'Saved'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),

      // /// ===== FAB CSKH =====
      // floatingActionButton: FloatingActionButton.small(
      //   onPressed: _openCustomerService,
      //   backgroundColor: Colors.red,
      //   child: const Icon(Icons.chat),
      // ),
    );
  }
}

/// ================= PRODUCT CARD =================
class _ProductCard extends StatelessWidget {
  final Product p;
  const _ProductCard({required this.p});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProductDetailScreen(productId: p.sanPhamId),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            Expanded(
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(14)),
                child: Image.network(
                  p.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                p.tenSanPham,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${p.giaBan} đ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
