import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/account_provider.dart';
import '../../models/account_profile.dart';
import '../auth_screen/auth_common.dart';

class MyDetailScreen extends StatefulWidget {
  const MyDetailScreen({super.key});

  @override
  State<MyDetailScreen> createState() => _MyDetailScreenState();
}

class _MyDetailScreenState extends State<MyDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _dob = TextEditingController();
  final _phone = TextEditingController();

  String _gender = 'Nam';
  bool _filledOnce = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadProfile();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _dob.dispose();
    _phone.dispose();
    super.dispose();
  }

  /// Hàm hiển thị thông báo đẹp mắt (Đồng bộ với LoginScreen)
  void _showStatusMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _fillForm(AccountProfile p) {
    _name.text = p.fullName ?? '';
    _email.text = p.email ?? '';
    _dob.text = p.dateOfBirth ?? '';
    _phone.text = p.phone ?? '';

    final g = (p.gender ?? '').toLowerCase();
    _gender = g == 'Nữ'
        ? 'Nữ'
        : g == 'Nam'
        ? 'Nam'
        : 'Khác';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dob.text) ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _dob.text =
      "${picked.year.toString().padLeft(4, '0')}-"
          "${picked.month.toString().padLeft(2, '0')}-"
          "${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AccountProvider>();

    final profile = AccountProfile(
      fullName: _name.text.trim(),
      dateOfBirth: _dob.text.trim(),
      gender: _gender,
      phone: _phone.text.trim(),
    );

    await provider.updateProfile(profile);

    if (!mounted) return;

    if (provider.error != null) {
      _showStatusMessage(provider.error!, isError: true);
      return;
    }

    _showStatusMessage('Cập nhật thành công!', isError: false);
  }


  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>();

    if (account.isLoading && account.profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (account.profile != null && !_filledOnce) {
      _fillForm(account.profile!);
      _filledOnce = true; // chỉ fill 1 lần
    }

    return Scaffold(
      appBar: const AppBackBar(title: 'Thông tin cá nhân'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: AppTheme.input('Họ tên'),
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 12),

              //  Email / tên đăng nhập (chỉ hiển thị)
              TextFormField(
                controller: _email,
                decoration: AppTheme.input('Email / Tên đăng nhập'),
                enabled: false,
              ),
              const SizedBox(height: 12),

              //  Date picker
              TextFormField(
                controller: _dob,
                readOnly: true,
                decoration: AppTheme.input('Ngày sinh').copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today_outlined),
                    onPressed: _pickDate,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: AppTheme.input('Giới tính'),
                value: ['Nam', 'Nữ', 'Khác'].contains(_gender)
                    ? _gender
                    : 'Nam',
                items: const [
                  DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                  DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                  DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                ],
                onChanged: (v) => setState(() => _gender = v ?? 'Male'),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _phone,
                decoration: AppTheme.input('Số điện thoại'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: AppTheme.primaryButton(context),
                onPressed: account.isLoading ? null : _submit,
                child: account.isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Cập nhật'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
