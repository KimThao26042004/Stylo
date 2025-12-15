import 'package:flutter/material.dart';
import 'auth_common.dart';
import 'login_screen.dart';

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
  final _confirmPassword = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;

  bool get _valid => _formKey.currentState?.validate() == true;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_valid) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: POST /auth/register
    setState(() => _submitting = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created (mock)')));
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text('Create an account',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text("Let's create your account.", style: TextStyle(color: AppTheme.lightText)),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                onChanged: () => setState(() {}),
                child: Column(children: [
                  TextFormField(
                    controller: _fullName,
                    textCapitalization: TextCapitalization.words,
                    decoration: AppTheme.input('Full Name', hint: 'Enter your full name'),
                    validator: (v) => (v == null || v.trim().length < 2) ? 'Name is too short' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: AppTheme.input('Email', hint: 'Enter your email address'),
                    validator: emailValidator,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    decoration: AppTheme.input('Password', hint: 'Enter your password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: passwordValidator,
                  ),
                  const SizedBox(height: 14), // Khoảng cách
                  // Thêm TextFormField cho nhập lại mật khẩu
                  TextFormField(
                    controller: _confirmPassword,
                    obscureText: _obscure,
                    decoration: AppTheme.input('Confirm Password', hint: 'Re-enter your password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    // Sử dụng hàm kiểm tra mới
                    validator: (v) => confirmPasswordValidator(v, _password.text),
                  ),
                  const SizedBox(height: 10),
                  const TermsLine(),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _valid && !_submitting ? _submit : null,
                    style: AppTheme.primaryButton(context),
                    child: _submitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Create an Account'),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              const OrDivider(),
              const SizedBox(height: 12),
              GoogleBtn(label: 'Sign Up with Google', onPressed: () {/* TODO */}),
              const SizedBox(height: 10),
              FacebookBtn(label: 'Sign Up with Facebook', onPressed: () {/* TODO */}),
              const SizedBox(height: 24),
              Center(
                child: Wrap(spacing: 6, children: [
                  const Text('Already have an account?'),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, LoginScreen.routeName),
                    child: const Text('Log In',
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
