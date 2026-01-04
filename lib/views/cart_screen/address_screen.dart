import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/account_provider.dart';
import '../auth_screen/auth_common.dart';
import 'new_address_screen.dart';
import 'update_address_screen.dart'; // Bạn cần tạo file này (xem ở dưới)

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const AppBackBar(title: 'Địa chỉ của tôi'),
      body: account.isLoading && account.addresses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: account.addresses.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final addr = account.addresses[index];
          return _buildAddressItem(addr);
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
        ]),
        child: ElevatedButton.icon(
          style: AppTheme.primaryButton(context),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NewAddressScreen()),
            );
            if (result == true) context.read<AccountProvider>().loadAddresses();
          },
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Thêm địa chỉ mới'),
        ),
      ),
    );
  }

  Widget _buildAddressItem(dynamic addr) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UpdateAddressScreen(address: addr)),
        );
        if (result == true) context.read<AccountProvider>().loadAddresses();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(addr.loaiDiaChi, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (addr.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE53935)),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text('Mặc định', style: TextStyle(color: Color(0xFFE53935), fontSize: 10)),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(addr.diaChiChiTiet, style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}