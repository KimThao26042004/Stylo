import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/account_provider.dart';
import '../auth_screen/auth_common.dart'; // Chứa AppTheme và AppBackBar
import '../auth_screen/login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  // Sử dụng controller để quản lý text nhập vào
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AccountProvider>();

    final success = await provider.changePassword(
      _oldPassController.text,
      _newPassController.text,
    );

    if (!mounted) return;

    if (success) {
      // Thông báo thành công và yêu cầu đăng nhập lại
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed. Please login again.'),
          backgroundColor: Colors.green,
        ),
      );

      // Điều hướng về Login và xóa hết stack (Logout sạch sẽ)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    } else {
      // Hiển thị lỗi từ Backend (Ví dụ: "Mật khẩu cũ không chính xác")
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Update failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>();

    return Scaffold(
      // Sử dụng AppBackBar để đồng bộ nút quay lại và style tiêu đề
      appBar: const AppBackBar(title: 'Change Password'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Mật khẩu cũ
              TextFormField(
                controller: _oldPassController,
                obscureText: true,
                decoration: AppTheme.input('Old Password'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // Mật khẩu mới
              TextFormField(
                controller: _newPassController,
                obscureText: true,
                decoration: AppTheme.input('New Password'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Xác nhận mật khẩu mới
              TextFormField(
                controller: _confirmPassController,
                obscureText: true,
                decoration: AppTheme.input('Confirm New Password'),
                validator: (v) {
                  if (v != _newPassController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Nút Submit sử dụng AppTheme và trạng thái Loading
              ElevatedButton(
                style: AppTheme.primaryButton(context),
                onPressed: account.isLoading ? null : _submit,
                child: account.isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Update Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}