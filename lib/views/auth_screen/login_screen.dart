import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';
import '../home_screen/home_screen.dart';

import 'auth_common.dart';
import 'forgotPass_screen.dart';
import 'signUp_screen.dart';
import 'VerificationCode_screen.dart';

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

  bool _shouldGoVerify(String? msg) {
    if (msg == null) return false;
    final m = msg.toLowerCase();
    return m.contains('verify') ||
        m.contains('verified') ||
        m.contains('otp') ||
        m.contains('not verified') ||
        m.contains('xác thực') ||
        m.contains('chưa xác thực');
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
      // ❌ Chỉ hiển thị lỗi, KHÔNG chuyển OTP
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!)),
      );
      return;
    }

    // ✅ Login OK → Home
    Navigator.pushReplacementNamed(
      context,
      HomeScreen.routeName,
    );
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
                    'Login to your account',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "It's great to see you again.",
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
                        onChanged: () => setState(() {}),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: AppTheme.input(
                                'Email',
                                hint: 'Enter your email address',
                              ),
                              validator: emailValidator,
                            ),

                            const SizedBox(height: 18),

                            TextFormField(
                              controller: _password,
                              obscureText: _obscure,
                              decoration: AppTheme
                                  .input('Password', hint: 'Enter your password')
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
                                child: const Text('Reset your password'),
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
                                    : const Text('Login'),
                              ),
                            ),

                            if (auth.error != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                auth.error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const OrDivider(),
                  const SizedBox(height: 16),

                  GoogleBtn(
                    label: 'Login with Google',
                    onPressed: () {/* TODO */},
                  ),
                  const SizedBox(height: 12),
                  FacebookBtn(
                    label: 'Login with Facebook',
                    onPressed: () {/* TODO */},
                  ),

                  const SizedBox(height: 28),

                  Center(
                    child: Wrap(
                      spacing: 6,
                      children: [
                        const Text("Don't have an account?"),
                        GestureDetector(
                          onTap: auth.isLoading
                              ? null
                              : () => Navigator.pushReplacementNamed(
                            context,
                            SignUpScreen.routeName,
                          ),
                          child: const Text(
                            'Join',
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
