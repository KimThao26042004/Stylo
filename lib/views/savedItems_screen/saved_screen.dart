import 'package:flutter/material.dart';
import '../auth_screen/auth_common.dart';
import '../../data/mock_db.dart';
import '../../state/favoritesStore.dart';
import '../home_screen/home_screen.dart';
import '../home_screen/search_screen.dart';
import '../cart_screen/cart_screen.dart';
import '../profile_screen/account_screen.dart';
import '../home_screen/notifications_screen.dart';

class SavedScreen extends StatefulWidget {
  static const String routeName = '/saved';
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final store = FavoritesStore.instance;
  int _tabIndex = 2; // Saved

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  // ---- Bottom nav ----
  void _onBottomTap(int i) {
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
          MaterialPageRoute(builder: (_) => const SearchScreen()),
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
        title: const Text('Saved', style: TextStyle(fontWeight: FontWeight.w700)),
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
      body: AnimatedBuilder(
        animation: store,
        builder: (_, __) {
          final items = store.items;
          if (items.isEmpty) return const _EmptySavedView();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GridView.builder(
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: .82,
              ),
              itemBuilder: (_, i) => _SavedCard(product: items[i]),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: _onBottomTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: 'Saved'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }
}

class _EmptySavedView extends StatelessWidget {
  const _EmptySavedView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
        Icon(Icons.favorite_border, size: 64, color: AppTheme.lightText),
        SizedBox(height: 16),
        Text('No Saved Items!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        SizedBox(height: 8),
        Text(
          "You don't have any saved items.\nGo to home and add some.",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.lightText),
        ),
      ]),
    );
  }
}

class _SavedCard extends StatelessWidget {
  final MockProduct product;
  const _SavedCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final store = FavoritesStore.instance;
    final hasDiscount = product.discountPercent != null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            child: AspectRatio(
              aspectRatio: 1.7,
              child: Image.network(product.imageUrl, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.favorite, color: Colors.red, size: 18),
                onPressed: () => store.toggle(product.id),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(children: [
            Text('\$ ${product.price.toInt()}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            if (hasDiscount) ...[
              const SizedBox(width: 6),
              Text('\$ ${(product.price * 1.3).toInt()}',
                  style: TextStyle(
                      color: Colors.grey[500],
                      decoration: TextDecoration.lineThrough)),
            ]
          ]),
        ),
      ]),
    );
  }
}
