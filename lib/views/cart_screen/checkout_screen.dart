import 'package:flutter/material.dart';
import '../auth_screen/auth_common.dart';
import 'address_screen.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBackBar(title: 'Checkout'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Home: 925 S Chugach St #APT 10, Alaska 99645'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const AddressScreen()));
                    },
                    child: const Text('Change'),
                  ),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Payment method
          const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: const [
              Chip(label: Text('Card')),
              Chip(label: Text('Cash')),
              Chip(label: Text('Apple Pay')),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('**** **** **** 2512'),
              trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
            ),
          ),
          const Divider(),
          // Order summary
          const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _row('Sub-total', 5870),
          _row('VAT (%)', 0),
          _row('Shipping fee', 80),
          const Divider(),
          _row('Total', 5950, bold: true),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: TextField(
                decoration: AppTheme.input('', hint: 'Enter promo code'),
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('Add')),
          ]),
          const SizedBox(height: 16),
          ElevatedButton(
            style: AppTheme.primaryButton(context),
            onPressed: () {},
            child: const Text('Place Order'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label),
      Text('\$ ${value.toStringAsFixed(0)}',
          style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
    ]),
  );
}
