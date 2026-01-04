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

  /// Hàm hiển thị thông báo đẹp mắt
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
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
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
      // Hiển thị thông báo thành công đẹp
      _showStatusMessage('Đổi mật khẩu thành công! Vui lòng đăng nhập lại.', isError: false);

      // Đợi một lát để user kịp nhìn thấy thông báo trước khi chuyển trang
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      });
    } else {
      // Hiển thị lỗi từ Backend
      _showStatusMessage(provider.error ?? 'Đổi mật khẩu thất bại', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>();

    return Scaffold(
      // Sử dụng AppBackBar để đồng bộ nút quay lại và style tiêu đề
      appBar: const AppBackBar(title: 'Đổi mật khẩu'),
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
                decoration: AppTheme.input('Mật khẩu cũ'),
                validator: (v) => (v == null || v.isEmpty) ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 12),

              // Mật khẩu mới
              TextFormField(
                controller: _newPassController,
                obscureText: true,
                decoration: AppTheme.input('Mật khẩu mới'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Bắt buộc';
                  if (v.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự.';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Xác nhận mật khẩu mới
              TextFormField(
                controller: _confirmPassController,
                obscureText: true,
                decoration: AppTheme.input('Xác nhận mật khẩu mới'),
                validator: (v) {
                  if (v != _newPassController.text) return 'Mật khẩu không khớp';
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
                    : const Text('Cập nhật mật khẩu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}