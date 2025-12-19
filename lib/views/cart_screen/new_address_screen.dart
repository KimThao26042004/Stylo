import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/account_provider.dart';
import '../auth_screen/auth_common.dart';

class NewAddressScreen extends StatefulWidget {
  const NewAddressScreen({super.key});

  @override
  State<NewAddressScreen> createState() => _NewAddressScreenState();
}

class _NewAddressScreenState extends State<NewAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  String _type = 'Home';
  final _detail = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _detail.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AccountProvider>();

    await provider.addAddress(
      diaChiChiTiet: _detail.text.trim(),
      loaiDiaChi: _type,
      isDefault: _isDefault,
    );

    if (!mounted) return;

    if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!)),
      );
      return;
    }

    // Báo thành công
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address added')),
    );

    // QUAY VỀ + TRẢ KẾT QUẢ
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>();

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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _type,
                      items: const [
                        DropdownMenuItem(value: 'Home', child: Text('Home')),
                        DropdownMenuItem(value: 'Office', child: Text('Office')),
                        DropdownMenuItem(
                            value: 'Apartment', child: Text('Apartment')),
                      ],
                      onChanged: (v) => setState(() => _type = v ?? 'Home'),
                      decoration: AppTheme.input('Address Nickname'),
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _detail,
                      decoration: AppTheme.input('Full Address'),
                      validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                    ),

                    Row(
                      children: [
                        Checkbox(
                          value: _isDefault,
                          onChanged: (v) =>
                              setState(() => _isDefault = v ?? false),
                        ),
                        const Text('Make this as a default address'),
                      ],
                    ),

                    ElevatedButton(
                      style: AppTheme.primaryButton(context),
                      onPressed: account.isLoading ? null : _submit,
                      child: account.isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                        CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Add'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
