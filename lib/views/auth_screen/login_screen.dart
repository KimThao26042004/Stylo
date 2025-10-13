import 'package:flutter/material.dart';
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
  bool _submitting = false;

  bool get _valid => _formKey.currentState?.validate() == true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_valid) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: POST /auth/login
    setState(() => _submitting = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login success (mock)')),
    );
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
              Text('Login to your account',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text("It's great to see you again.", style: TextStyle(color: AppTheme.lightText)),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                onChanged: () => setState(() {}),
                child: Column(children: [
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
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, ForgotPassScreen.routeName),
                      child: const Text('Reset your password'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _valid && !_submitting ? _submit : null,
                    style: AppTheme.primaryButton(context),
                    child: _submitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Login'),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              const OrDivider(),
              const SizedBox(height: 12),
              GoogleBtn(label: 'Login with Google', onPressed: () {/* TODO */}),
              const SizedBox(height: 10),
              FacebookBtn(label: 'Login with Facebook', onPressed: () {/* TODO */}),
              const SizedBox(height: 24),
              Center(
                child: Wrap(spacing: 6, children: [
                  const Text("Don't have an account?"),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, SignUpScreen.routeName),
                    child: const Text('Join',
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
