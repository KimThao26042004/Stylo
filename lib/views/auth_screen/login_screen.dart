import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import '../home_screen/home_screen.dart';
import 'auth_common.dart';
import 'forgotPass_screen.dart';
import 'signUp_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  bool get _valid => _formKey.currentState?.validate() == true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // Hàm hiển thị thông báo (Dùng chung cho cả lỗi và thành công)
  void _showStatusMessage(String message, {bool isError = true}) {
    // Xóa SnackBar cũ trước khi hiện cái mới
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

  Future<void> _submit() async {
    if (!_valid) return;

    final auth = context.read<AuthProvider>();

    await auth.login(
      _email.text.trim(),
      _password.text,
    );

    if (!mounted) return;

    if (auth.error != null) {
      _showStatusMessage(auth.error!, isError: true);
      return;
    }

    // Thông báo đăng nhập thành công trước khi chuyển trang
    _showStatusMessage('Đăng nhập thành công!', isError: false);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    });
  }


  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  /// ===== TITLE =====
                  Text(
                    'Đăng nhập tài khoản',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Rất vui được gặp lại bạn!",
                    style: TextStyle(color: AppTheme.lightText),
                  ),

                  const SizedBox(height: 28),

                  /// ===== FORM CARD =====
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
                          // Mỗi khi form thay đổi, xóa lỗi cũ trong Provider để nút bấm cập nhật trạng thái
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
                                hint: 'Nhập địa chỉ Email của bạn',
                              ),
                              validator: emailValidator,
                            ),

                            const SizedBox(height: 18),

                            TextFormField(
                              controller: _password,
                              obscureText: _obscure,
                              decoration: AppTheme
                                  .input('Mật khẩu', hint: 'Nhập mật kẩu của bạn')
                                  .copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: passwordValidator,
                            ),

                            const SizedBox(height: 12),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: auth.isLoading
                                    ? null
                                    : () => Navigator.pushNamed(
                                  context,
                                  ForgotPassScreen.routeName,
                                ),
                                child: const Text('Quên mật khẩu?'),
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// ===== LOGIN BUTTON =====
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                (_valid && !auth.isLoading) ? _submit : null,
                                style: AppTheme.primaryButton(context),
                                child: auth.isLoading
                                    ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text('Đăng nhập'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const OrDivider(),
                  const SizedBox(height: 16),

                  GoogleBtn(
                    label: 'Đăng nhập với Google',
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  FacebookBtn(
                    label: 'Đăng nhập với Facebook',
                    onPressed: () {},
                  ),

                  const SizedBox(height: 28),

                  Center(
                    child: Wrap(
                      spacing: 6,
                      children: [
                        const Text("Bạn chưa có tài khoản?"),
                        GestureDetector(
                          onTap: auth.isLoading
                              ? null
                              : () => Navigator.pushReplacementNamed(
                            context,
                            SignUpScreen.routeName,
                          ),
                          child: const Text(
                            'Đăng ký ngay',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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