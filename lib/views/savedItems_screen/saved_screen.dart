import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home_screen/home_screen.dart';
import '../categories/categories_screen.dart';
import '../cart_screen/cart_screen.dart';
import '../profile_screen/account_screen.dart';
import '../home_screen/notifications_screen.dart';

import '../../models/product.dart';
import '../../models/product_detail.dart';
import '../../state/saved_provider.dart';
import '../../widgets/product_card.dart';

class SavedScreen extends StatefulWidget {
  static const String routeName = '/saved';
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  int _tabIndex = 2;

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  void _onBottomTap(int i) {
    if (_tabIndex == i) return;
    setState(() => _tabIndex = i);

    switch (i) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CategoriesScreen()),
        );
        break;
      case 2:
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AccountScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yêu thích',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _openNotifications,
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),

      /// ===== BODY =====
      body: Consumer<SavedProvider>(
        builder: (context, saved, _) {
          final items = saved.items;

          if (items.isEmpty) {
            return const _EmptySavedView();
          }

          /// convert ProductDetail → Product (CHỈ ĐỂ HIỂN THỊ)
          final products = items
              .map(
                (p) => Product(
              sanPhamId: p.sanPhamId,
              tenSanPham: p.name,
              giaBan: p.basePrice,
              imageUrl: p.imageUrl,
            ),
          )
              .toList();

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.63,
            ),
            itemBuilder: (_, i) => ProductCard(product: products[i]),
          );
        },
      ),

      /// ===== BOTTOM NAV =====
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
              icon: Icon(Icons.favorite), label: 'Yêu thích'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined), label: 'Giỏ hàng'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Tài khoản'),
        ],
      ),
    );
  }
}

/// ===== EMPTY STATE =====
class _EmptySavedView extends StatelessWidget {
  const _EmptySavedView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No Saved Items!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            "Bạn chưa có sản phẩm yêu thích.\nHãy đến trang chủ và thêm sản phẩm yêu thích nhé !.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
