import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/product_service.dart';
import 'subcategories_screen.dart';
import '../home_screen/home_screen.dart';
import '../cart_screen/cart_screen.dart';
import '../profile_screen/account_screen.dart';
import '../home_screen/notifications_screen.dart';
import '../savedItems_screen/saved_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool _loading = true;
  String? _error;
  List<Category> _phanLoai = [];

  int _tabIndex = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await ProductService.getPhanLoai();
      if (!mounted) return;
      setState(() {
        _phanLoai = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  // ---- Bottom nav ----
  void _onBottomTap(int i) {
    if (i == _tabIndex) return;

    setState(() => _tabIndex = i);

    switch (i) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;

      case 1:
        break;

      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SavedScreen()),
        );
        break;

      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        );
        break;

      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AccountScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân loại', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
              onPressed: _openNotifications,
              icon: const Icon(Icons.notifications_none)),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: ListView.separated(
        itemCount: _phanLoai.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final pl = _phanLoai[i];
          return ListTile(
            title: Text(pl.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubCategoriesScreen(
                    phanLoaiId: pl.id,
                    phanLoaiName: pl.name,
                  ),
                ),
              );
            },
          );
        },
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
