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

  Future<void> _sendCode() async {
    if (!_valid) return;

    final auth = context.read<AuthProvider>();
    final email = _email.text.trim();

    await auth.forgotPassword(email);

    if (!mounted) return;

    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!)),
      );
      return;
    }

    //  qua OTP screen với flow = reset
    Navigator.pushNamed(
      context,
      VerificationCodeScreen.routeName,
      arguments: {
        "email": email,
        "flow": "forgot",
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: const AppBackBar(title: 'Forgot Password'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Enter your email',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text(
              'Enter your email for the verification process. We will send 4 digits code to your email.',
              style: TextStyle(color: AppTheme.lightText),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              onChanged: () => setState(() {}),
              child: Column(children: [
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: AppTheme.input('Email', hint: 'you@example.com'),
                  validator: emailValidator,
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _valid && !auth.isLoading ? _sendCode : null,
                  style: AppTheme.primaryButton(context),
                  child: auth.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Send Code'),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
