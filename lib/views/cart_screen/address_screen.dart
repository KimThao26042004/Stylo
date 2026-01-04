import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/account_provider.dart';
import '../auth_screen/auth_common.dart';
import 'new_address_screen.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  int? _selectedId;        // address user đang chọn (UI)
  int? _initialDefaultId; // default thật từ backend
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAddresses();
    });
  }

  void _initDefault(AccountProvider account) {
    if (_initialized || account.addresses.isEmpty) return;

    final defaultAddr = account.addresses.firstWhere(
          (a) => a.isDefault,
      orElse: () => account.addresses.first,
    );

    _initialDefaultId = defaultAddr.diaChiId;
    _selectedId = defaultAddr.diaChiId;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>();

    if (account.isLoading && account.addresses.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    _initDefault(account);

    return Scaffold(
      appBar: const AppBackBar(title: 'Địa chỉ'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...account.addresses.map((addr) {
            final isSelected = _selectedId == addr.diaChiId;
            final isDefault = _initialDefaultId == addr.diaChiId;

            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() => _selectedId = addr.diaChiId);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 10),

                    /// Address info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                addr.loaiDiaChi,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isDefault)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'MẶC ĐỊNH',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color:
                                      Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            addr.diaChiChiTiet,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Delete
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Xoá địa chỉ'),
                            content: const Text(
                              'Bạn có chắc muốn xoá địa chỉ này không?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Huỷ'),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Xoá'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && mounted) {
                          await context
                              .read<AccountProvider>()
                              .deleteAddress(addr.diaChiId);

                          _initialized = false;
                          context
                              .read<AccountProvider>()
                              .loadAddresses();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }),

          /// Add new
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Thêm địa chỉ mới'),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NewAddressScreen(),
                ),
              );

              if (result == true && mounted) {
                _initialized = false;
                context.read<AccountProvider>().loadAddresses();
              }
            },
          ),
        ],
      ),

      /// APPLY
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: AppTheme.primaryButton(context),
          onPressed: (_selectedId == null ||
              _selectedId == _initialDefaultId)
              ? null
              : () async {
            await context
                .read<AccountProvider>()
                .setDefaultAddress(_selectedId!);

            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                Text('Đã đặt làm địa chỉ mặc định'),
              ),
            );

            Navigator.pop(context);
          },
          child: const Text('Cập nhật'),
        ),
      ),
    );
  }
}
