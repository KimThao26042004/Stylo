import 'package:flutter/material.dart';
import '../auth_screen/auth_common.dart';
import 'new_address_screen.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  int _selected = 0;
  final addresses = [
    'Home: 925 S Chugach St #APT 10, Alaska 99645',
    'Office: 2438 6th Ave, Ketchikan, Alaska 99901',
    'Apartment: 251 Vista Dr #8301, Juneau, Alaska 99801',
    'Parent\'s House: 4821 Ridge Top Cir, Anchorage, Alaska 99502',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBackBar(title: 'Address'),
      body: ListView.builder(
        itemCount: addresses.length + 1,
        itemBuilder: (_, i) {
          if (i == addresses.length) {
            return ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add New Address'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NewAddressScreen()));
              },
            );
          }
          return RadioListTile<int>(
            value: i,
            groupValue: _selected,
            onChanged: (v) => setState(() => _selected = v!),
            title: Text(addresses[i]),
            secondary: i == 0
                ? const Chip(label: Text('Default'), backgroundColor: Colors.black12)
                : null,
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: AppTheme.primaryButton(context),
          onPressed: () => Navigator.pop(context),
          child: const Text('Apply'),
        ),
      ),
    );
  }
}
