import 'package:flutter/material.dart';
import '../auth_screen/auth_common.dart';

class NewAddressScreen extends StatelessWidget {
  const NewAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBackBar(title: 'New Address'),
      body: Stack(
        children: [
          Container(color: Colors.grey.shade300), // giả lập map
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    items: const [
                      DropdownMenuItem(value: 'Home', child: Text('Home')),
                      DropdownMenuItem(value: 'Office', child: Text('Office')),
                      DropdownMenuItem(value: 'Apartment', child: Text('Apartment')),
                    ],
                    onChanged: (_) {},
                    decoration: AppTheme.input('Address Nickname'),
                  ),
                  const SizedBox(height: 10),
                  TextField(decoration: AppTheme.input('Full Address')),
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: (_) {}),
                      const Text('Make this as a default address'),
                    ],
                  ),
                  ElevatedButton(
                    style: AppTheme.primaryButton(context),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
