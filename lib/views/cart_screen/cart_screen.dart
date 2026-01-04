import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/cart_provider.dart';
import '../../models/cart_item.dart';
import '../home_screen/home_screen.dart';
import '../cart_screen/checkout_screen.dart';
import '../categories/categories_screen.dart';
import '../savedItems_screen/saved_screen.dart';
import '../profile_screen/account_screen.dart';
import '../home_screen/notifications_screen.dart';

class CartScreen extends StatefulWidget {
  static const String routeName = '/cart';
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _tabIndex = 3;

  static const double _shippingFee = 30000;
  static const double _vat = 0.0;

  void _onBottomTap(int i) {
    setState(() => _tabIndex = i);
    switch (i) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        break;
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
        break;
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SavedScreen()));
        break;
      case 3:
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AccountScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    final subTotal = cart.subTotal;
    final total = subTotal + _shippingFee + _vat;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Giỏ hàng',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),

      /// ================= BODY =================
      body: items.isEmpty
          ? const _EmptyCartView()
          : Column(
        children: [
          /// LIST CART
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (_, i) => _CartItem(item: items[i]),
            ),
          ),

          /// SUMMARY
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              children: [
                _summaryRow('Tổng phụ', subTotal),
                _summaryRow('VAT (%)', _vat),
                _summaryRow('Phí vận chuyển', _shippingFee),
                const Divider(),
                _summaryRow('Tổng', total, bold: true),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                      );
                    },
                    child: const Text(
                      'Go To Checkout  →',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      /// ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: _onBottomTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Phân loại'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Yêu thích'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined), label: 'Giỏ hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tài khoản'),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '${value.toStringAsFixed(0)} đ',
            style: TextStyle(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/* =================== CART ITEM =================== */
class _CartItem extends StatelessWidget {
  final CartItem item;
  const _CartItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.product.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Màu sắc: ${item.colorName} • Kích cỡ: ${item.sizeName}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),

                const SizedBox(height: 6),
                Text(
                  '${item.price} đ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => cart.remove(item),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
          _QtyStepper(
            qty: item.quantity,
            onInc: () => cart.increaseQty(item),
            onDec: () => cart.decreaseQty(item),
          ),
        ],
      ),
    );
  }
}

/* =================== QTY STEPPER =================== */
class _QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onInc, onDec;
  const _QtyStepper({
    required this.qty,
    required this.onInc,
    required this.onDec,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _btn(Icons.remove, onDec, disabled: qty <= 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$qty',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          _btn(Icons.add, onInc),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap, {bool disabled = false}) {
    return InkWell(
      onTap: disabled ? null : onTap,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(
          icon,
          size: 18,
          color: disabled ? Colors.grey : Colors.black,
        ),
      ),
    );
  }
}

/* =================== EMPTY CART =================== */
class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Giỏ hàng rỗng!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
