import 'package:flutter/material.dart';
import '../auth_screen/auth_common.dart';
import '../order_screen/myOrders_screen.dart';
import 'changePassword_screen.dart';
import 'myDetail_screen.dart';
import 'setupNotification_screen.dart';
import '../cart_screen/address_screen.dart';
import '../home_screen/home_screen.dart';
import '../categories/categories_screen.dart';
import '../savedItems_screen/saved_screen.dart';
import '../cart_screen/cart_screen.dart';
import '../auth_screen/login_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int _tabIndex = 4; // Account

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
          MaterialPageRoute(builder: (_) => const CategoriesScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SavedScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        );
        break;
      case 4:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
      ),      body: ListView(
        children: [
          _tile(context, Icons.inventory_2_outlined, 'My Orders', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
            );
          }),
          _divider(),
          _tile(context, Icons.person_outline, 'My Details', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyDetailScreen()),
            );
          }),
          // Change Password
          _tile(context, Icons.lock_outline, 'Change Password', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            );
          }),
          _tile(context, Icons.home_outlined, 'Address Book', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddressScreen()),
            );
          }),
          _tile(context, Icons.credit_card_outlined, 'Payment Methods', () {}),
          _tile(context, Icons.notifications_none, 'Notifications', () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            );
          }),
          _divider(),
          _tile(context, Icons.help_outline, 'FAQs', () {}),
          _tile(context, Icons.headset_mic_outlined, 'Help Center', () {}),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            onTap: () {
              // TODO: clear token / user nếu có (sau này)

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },

          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: _onBottomTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
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

  Widget _tile(BuildContext c, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _divider() => Divider(color: Colors.grey.shade300, height: 1);
}
