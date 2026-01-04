import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'notifications_screen.dart';
import 'search_screen.dart';
import 'search_by_image_screen.dart';
import '../../state/product_provider.dart';
import '../savedItems_screen/saved_screen.dart';
import '../cart_screen/cart_screen.dart';
import '../profile_screen/account_screen.dart';
import '../categories/categories_screen.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  int? _selectedCatId; // null = All
  late PageController _pageController;
  int _currentPage = 0;

  // Timer to auto change the page
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Set up the timer to auto scroll the banner every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < 3) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });

    Future.microtask(
          () => context.read<ProductProvider>().loadHome(),
    );
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
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

  void _openSearch_by_image() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchByImageScreen()),
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
      backgroundColor: Colors.red,
      appBar: AppBar(
        title: const Text('Stylo', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red,)),
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
            // ===== SEARCH =====
            TextField(
              readOnly: true,
              onTap: _openSearch,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Tìm kiếm...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_a_photo_outlined),
                  onPressed: _openSearch_by_image,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ===== PHÂN LOẠI =====
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: provider.phanLoai.length + 1, // +1 for "All"
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ChoiceChip(
                      label: const Text('Tất cả'),
                      selected: provider.selectedPhanLoaiId == null,
                      onSelected: (_) {
                        provider.loadHome();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }
                  final pl = provider.phanLoai[index - 1];
                  final selected = provider.selectedPhanLoaiId == pl.id;

                  return ChoiceChip(
                    label: Text(pl.name),
                    selected: selected,
                    onSelected: (_) {
                      provider.selectPhanLoai(pl.id);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // ===== BANNER (Auto Scrolling) =====
            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _pageController,
                itemCount: 4,
                itemBuilder: (_, index) {
                  String imagePath = [
                    'Content/banner/banner1.jpg',
                    'Content/banner/banner2.jpg',
                    'Content/banner/banner3.jpg',
                    'Content/banner/banner4.jpg',
                  ][index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // ===== GRID SẢN PHẨM (10 SP) =====
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.63,
              ),
              itemBuilder: (_, i) => ProductCard(product: products[i]),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.home_filled), label: 'Trang chủ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: 'Phân loại'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: 'Yêu thích'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined), label: 'Giỏ hàng'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Tài khoản'),
        ],
      ),
    );
  }
}
