import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/account_provider.dart';
import '../auth_screen/auth_common.dart';
import '../auth_screen/login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool get _isValid => _formKey.currentState?.validate() ?? false;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _showStatus(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 14))),
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
    if (!_isValid) return;

    final provider = context.read<AccountProvider>();
    final success = await provider.changePassword(
      _oldPassController.text,
      _newPassController.text,
    );

    if (!mounted) return;

    if (success) {
      _showStatus('Đổi mật khẩu thành công! Vui lòng đăng nhập lại.', isError: false);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      });
    } else {
      _showStatus(provider.error ?? 'Cập nhật thất bại', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: const AppBackBar(title: 'Đổi mật khẩu'),
      body: SafeArea(
        child: SingleChildScrollView(
          // Giữ padding giống mẫu cũ để TextField dài và thoáng
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            onChanged: () {
              if (account.error != null) account.clearError();
              setState(() {});
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cập nhật mật khẩu mới',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mật khẩu mới của bạn nên khác với mật khẩu đã sử dụng trước đó.',
                  style: TextStyle(color: AppTheme.lightText, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Mật khẩu cũ - TextField trải dài
                TextFormField(
                  controller: _oldPassController,
                  obscureText: _obscureOld,
                  onChanged: (_) => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  decoration: AppTheme.input('Mật khẩu hiện tại').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureOld = !_obscureOld),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu hiện tại' : null,
                ),
                const SizedBox(height: 16),

                // Mật khẩu mới - TextField trải dài
                TextFormField(
                  controller: _newPassController,
                  obscureText: _obscureNew,
                  onChanged: (_) => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  decoration: AppTheme.input('Mật khẩu mới', hint: 'Tối thiểu 6 ký tự').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                  validator: passwordValidator,
                ),
                const SizedBox(height: 16),

                // Xác nhận mật khẩu - TextField trải dài
                TextFormField(
                  controller: _confirmPassController,
                  obscureText: _obscureConfirm,
                  onChanged: (_) => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  decoration: AppTheme.input('Xác nhận mật khẩu mới').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) => confirmPasswordValidator(v, _newPassController.text),
                ),
                const SizedBox(height: 32),

                // Nút bấm trải dài Full Width
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: AppTheme.primaryButton(context),
                    onPressed: (_isValid && !account.isLoading) ? _submit : null,
                    child: account.isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                        : const Text(
                      'Cập nhật mật khẩu',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}