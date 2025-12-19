import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../state/account_provider.dart';
import '../auth_screen/auth_common.dart';
import '../cart_screen/address_screen.dart';
import '../order_screen/myOrders_screen.dart';

enum PaymentMethod { card, cash, applePay }

class CheckoutScreen extends StatefulWidget {
  final double subTotal;

  const CheckoutScreen({
    super.key,
    required this.subTotal,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const double _shippingFee = 30;
  static const double _vat = 0;

  PaymentMethod _payment = PaymentMethod.cash;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAddresses();
    });
  }

  DateTime get _deliveryDate =>
      DateTime.now().add(const Duration(days: 3));

  double get _total =>
      widget.subTotal + _shippingFee + _vat;

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>();

    final defaultAddress = account.addresses
        .where((a) => a.isDefault)
        .toList();

    return Scaffold(
      appBar: const AppBackBar(title: 'Checkout'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /* ================= DELIVERY ADDRESS ================= */
          _sectionTitle('Delivery Address'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (account.isLoading)
                      const Text('Loading address...')
                    else if (defaultAddress.isEmpty)
                      const Text(
                        'Chưa có địa chỉ mặc định',
                        style: TextStyle(color: Colors.red),
                      )
                    else
                      Text(
                        '${defaultAddress.first.loaiDiaChi}: ${defaultAddress.first.diaChiChiTiet}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    TextButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddressScreen(),
                          ),
                        );
                        if (!mounted) return;
                        context.read<AccountProvider>().loadAddresses();
                      },
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 32),

          /* ================= DELIVERY DATE ================= */
          _sectionTitle('Estimated Delivery'),
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd/MM/yyyy').format(_deliveryDate),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const Divider(height: 32),

          /* ================= PAYMENT METHOD ================= */
          _sectionTitle('Payment Method'),
          _paymentTile(
            PaymentMethod.card,
            Icons.credit_card,
            'Card',
          ),
          _paymentTile(
            PaymentMethod.cash,
            Icons.payments_outlined,
            'Cash on Delivery',
          ),
          _paymentTile(
            PaymentMethod.applePay,
            Icons.apple,
            'Apple Pay',
          ),

          const Divider(height: 32),

          /* ================= ORDER SUMMARY ================= */
          _sectionTitle('Order Summary'),
          _row('Sub-total', widget.subTotal),
          _row('VAT (%)', _vat),
          _row('Shipping fee', _shippingFee),
          const Divider(),
          _row('Total', _total, bold: true),

          const SizedBox(height: 20),

          /* ================= PLACE ORDER ================= */
          ElevatedButton(
            style: AppTheme.primaryButton(context),
            onPressed: defaultAddress.isEmpty
                ? null
                : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đặt hàng thành công 🎉'),
                ),
              );

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyOrdersScreen(),
                ),
                    (_) => false,
              );
            },
            child: const Text('Place Order'),
          ),
        ],
      ),
    );
  }

  /* ================= UI HELPERS ================= */

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    ),
  );

  Widget _row(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '\$ ${value.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentTile(
      PaymentMethod value,
      IconData icon,
      String label,
      ) {
    return RadioListTile<PaymentMethod>(
      value: value,
      groupValue: _payment,
      onChanged: (v) => setState(() => _payment = v!),
      title: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
