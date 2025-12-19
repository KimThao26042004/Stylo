import 'package:flutter/material.dart';
import '../auth_screen/auth_common.dart';
import '../../data/mock_db.dart';
import 'checkout_screen.dart';
import '../home_screen/home_screen.dart';
import '../savedItems_screen/saved_screen.dart';
import '../profile_screen/account_screen.dart';
import '../categories/categories_screen.dart';

class CartScreen extends StatefulWidget {
  static const String routeName = '/cart';
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // mock cart (thay bằng store/service khi nối backend)
  final Map<MockProduct, int> cart = {
    MockDb.products[0]: 2,
    MockDb.products[1]: 1,
    MockDb.products[2]: 1,
  };

  int _tabIndex = 3; // Cart tab

  void _onBottomTap(int i) {
    setState(() => _tabIndex = i);
    switch (i) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));

    break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedScreen()));
        break;
      case 3:
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen()));
        break;
    }
  }

  void _inc(MockProduct p) => setState(() => cart[p] = (cart[p] ?? 0) + 1);
  void _dec(MockProduct p) => setState(() {
    final current = cart[p] ?? 1;
    cart[p] = current > 1 ? current - 1 : 1;
  });
  void _remove(MockProduct p) => setState(() => cart.remove(p));

  double get _subTotal =>
      cart.entries.fold(0.0, (sum, e) => sum + (e.key.price * e.value));
  static const double _shipping = 30.000;
  static const double _vat = 0.0;

  @override
  Widget build(BuildContext context) {
    final hasItems = cart.isNotEmpty;
    final total = _subTotal + _shipping + _vat;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
      ),
      body: hasItems
          ? Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.length,
              itemBuilder: (_, i) {
                final entry = cart.entries.elementAt(i);
                return _CartItem(
                  product: entry.key,
                  qty: entry.value,
                  onInc: () => _inc(entry.key),
                  onDec: () => _dec(entry.key),
                  onRemove: () => _remove(entry.key),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                _summaryRow('Sub-total', _subTotal),
                _summaryRow('VAT (%)', _vat),
                _summaryRow('Shipping fee', _shipping),
                const Divider(),
                _summaryRow('Total', total, bold: true),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: AppTheme.primaryButton(context),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckoutScreen(
                          subTotal: _subTotal,
                        ),
                      ),
                    );
                  },
                  child: const Text('Go To Checkout  →'),
                ),
              ],
            ),
          ),
        ],
      )
          : const _EmptyCartView(),
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
    );
  }

  Widget _summaryRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('\$ ${value.toStringAsFixed(0)}',
              style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
        ],
      ),
    );
  }
}

/* =================== Item trong Cart =================== */
class _CartItem extends StatelessWidget {
  final MockProduct product;
  final int qty;
  final VoidCallback onInc, onDec, onRemove;
  const _CartItem({
    required this.product,
    required this.qty,
    required this.onInc,
    required this.onDec,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(product.imageUrl, width: 72, height: 72, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Size L', style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 6),
                Text('\$ ${product.price.toInt()}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Remove',
          ),
          _QtyStepper(qty: qty, onInc: onInc, onDec: onDec),
        ],
      ),
    );
  }
}

/* =================== Stepper +/- =================== */
class _QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onInc, onDec;
  const _QtyStepper({required this.qty, required this.onInc, required this.onDec});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        _stepBtn(icon: Icons.remove, onTap: onDec, disabled: qty <= 1),
        Container(width: 1, height: 34, color: Colors.grey.shade300),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Container(width: 1, height: 34, color: Colors.grey.shade300),
        _stepBtn(icon: Icons.add, onTap: onInc),
      ]),
    );
  }

  Widget _stepBtn({required IconData icon, required VoidCallback onTap, bool disabled = false}) {
    return InkWell(
      onTap: disabled ? null : onTap,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(icon, size: 18, color: disabled ? Colors.grey : Colors.black),
      ),
    );
  }
}

/* =================== Empty-state =================== */
class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.shopping_cart_outlined, size: 64, color: AppTheme.lightText),
                SizedBox(height: 16),
                Text('Your Cart Is Empty!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                SizedBox(height: 8),
                Text("When you add products, they'll appear here.",
                    style: TextStyle(color: AppTheme.lightText)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
