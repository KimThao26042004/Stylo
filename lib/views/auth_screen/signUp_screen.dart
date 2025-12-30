import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import 'auth_common.dart';
import 'login_screen.dart';
import 'VerificationCode_screen.dart';

class SignUpScreen extends StatefulWidget {
  static const String routeName = '/signup';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  bool get _valid => _formKey.currentState?.validate() == true;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // Hàm ẩn SnackBar nhanh và clear lỗi Provider
  void _clearState() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    context.read<AuthProvider>().clearError();
  }

  void _showStatusMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Xóa cái cũ ngay lập tức
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_valid) return;

    final auth = context.read<AuthProvider>();
    final fullName = _fullName.text.trim();
    final email = _email.text.trim();
    final password = _password.text;

    await auth.register(_fullName.text.trim(), email, _password.text);

    if (!mounted) return;

    if (auth.error != null) {
      _showStatusMessage(auth.error!, isError: true);
      return;
    }

    // --- HIỂN THỊ THÔNG BÁO THÀNH CÔNG ---
    _showStatusMessage('Đăng ký thành công! Vui lòng kiểm tra email.', isError: false);

    // Đợi một chút để người dùng kịp nhìn thấy thông báo thành công trước khi chuyển trang
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        VerificationCodeScreen.routeName,
        arguments: {
          "email": email,
          "flow": "signup",
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text('Tạo tài khoản',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text("Đăng ký để bắt đầu trải nghiệm dịch vụ của chúng tôi.", style: TextStyle(color: AppTheme.lightText)),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                onChanged: () {
                  // Xóa lỗi hệ thống ngay khi người dùng bắt đầu sửa Form
                  if (auth.error != null) auth.clearError();
                  setState(() {});
                },
                child: Column(children: [
                  TextFormField(
                    controller: _fullName,
                    onChanged: (_) => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                    textCapitalization: TextCapitalization.words,
                    decoration: AppTheme.input('Họ và tên', hint: 'VD: Nguyễn Văn A'),
                    validator: (v) => (v == null || v.trim().length < 2) ? 'Tên quá ngắn. Vui lòng nhập thêm ký tự' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _email,
                    onChanged: (_) => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                    keyboardType: TextInputType.emailAddress,
                    decoration: AppTheme.input('Email', hint: 'VD: a@gmail.com'),
                    validator: emailValidator,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _password,
                    onChanged: (_) => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                    obscureText: _obscure,
                    decoration: AppTheme.input('Mật khẩu', hint: 'Ít nhất 6 ký tự').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: passwordValidator,
                  ),
                  const SizedBox(height: 10),
                  const TermsLine(),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _valid && !auth.isLoading ? _submit : null,
                    style: AppTheme.primaryButton(context),
                    child: auth.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Đăng ký ngay'),
                  ),
                ]),
              ),
              const SizedBox(height: 24),
              Center(
                child: Wrap(spacing: 6, children: [
                  const Text('Bạn đã có tài khoản?'),
                  GestureDetector(
                    onTap: auth.isLoading
                        ? null
                        : () => Navigator.pushReplacementNamed(context, LoginScreen.routeName),
                    child: const Text('Đăng nhập',
                        style: TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
