import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import 'auth_common.dart';
import 'VerificationCode_screen.dart';

class ForgotPassScreen extends StatefulWidget {
  static const String routeName = '/forgot';
  const ForgotPassScreen({super.key});

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  bool get _valid => _formKey.currentState?.validate() == true;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  // Thông báo lỗi dạng Floating
  void _showNotification(String message, {bool isError = true}) {
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

  Future<void> _sendCode() async {
    if (!_valid) return;

    final auth = context.read<AuthProvider>();
    final email = _email.text.trim();

    await auth.forgotPassword(email);

    if (!mounted) return;

    if (auth.error != null) {
      _showNotification(auth.error!, isError: true);
      return;
    }

    // Thông báo thành công
    _showNotification('Mã xác thực đã được gửi đến email của bạn', isError: false);

    // Chờ một chút để người dùng đọc thông báo trước khi chuyển trang
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        VerificationCodeScreen.routeName,
        arguments: {
          "email": email,
          "flow": "forgot",
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: const AppBackBar(title: 'Quên mật khẩu'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nhập Email của bạn',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vui lòng nhập địa chỉ email đã đăng ký. '
                        'Chúng tôi sẽ gửi mã xác thực gồm 4 chữ số để khôi phục mật khẩu.',
                    style: TextStyle(color: AppTheme.lightText),
                  ),

                  const SizedBox(height: 28),

                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        onChanged: () {
                          // QUAN TRỌNG: Xóa lỗi hệ thống khi người dùng bắt đầu chỉnh sửa lại email
                          if (auth.error != null) auth.clearError();
                          setState(() {});
                        },
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: AppTheme.input(
                                'Email',
                                hint: 'a@example.com',
                              ),
                              validator: emailValidator,
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                _valid && !auth.isLoading ? _sendCode : null,
                                style: AppTheme.primaryButton(context),
                                child: auth.isLoading
                                    ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text('Gửi mã xác thực'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
