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

  Future<void> _submit() async {
    if (!_valid) return;

    final auth = context.read<AuthProvider>();
    final fullName = _fullName.text.trim();
    final email = _email.text.trim();
    final password = _password.text;

    await auth.register(fullName, email, password);

    if (!mounted) return;

    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!)),
      );
      return;
    }

    // ✅ qua OTP screen với flow = signup
    Navigator.pushReplacementNamed(
      context,
      VerificationCodeScreen.routeName,
      arguments: {
        "email": email,
        "flow": "signup",
      },
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

                  Text(
                    'Create an account',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Let's create your account.",
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
                        onChanged: () => setState(() {}),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _fullName,
                              textCapitalization: TextCapitalization.words,
                              decoration: AppTheme.input(
                                'Full Name',
                                hint: 'Enter your full name',
                              ),
                              validator: (v) =>
                              (v == null || v.trim().length < 2)
                                  ? 'Name is too short'
                                  : null,
                            ),

                            const SizedBox(height: 18),

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
                                  .input(
                                'Password',
                                hint: 'Enter your password',
                              )
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

                            const SizedBox(height: 14),
                            const TermsLine(),
                            const SizedBox(height: 18),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                _valid && !auth.isLoading ? _submit : null,
                                style: AppTheme.primaryButton(context),
                                child: auth.isLoading
                                    ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text('Create an Account'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  Center(
                    child: Wrap(
                      spacing: 6,
                      children: [
                        const Text('Already have an account?'),
                        GestureDetector(
                          onTap: auth.isLoading
                              ? null
                              : () => Navigator.pushReplacementNamed(
                            context,
                            LoginScreen.routeName,
                          ),
                          child: const Text(
                            'Log In',
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
