import 'package:flutter/material.dart';
import 'auth_common.dart';
import 'ResetPass_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  static const String routeName = '/verify';
  final String email;
  const VerificationCodeScreen({super.key, required this.email});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final _cells = List.generate(4, (_) => TextEditingController());
  bool _submitting = false;
  String get _code => _cells.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in _cells) c.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_code.length != 4 || _code.contains(RegExp(r'[^0-9]'))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter 4 digits')));
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: POST /auth/verify-otp { email, code }
    setState(() => _submitting = false);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, ResetPassScreen.routeName);
  }

  Future<void> _resend() async {
    // TODO: POST /auth/resend-otp
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resent code (mock)')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBackBar(title: 'Verification Code'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Enter 4 Digit Code',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: AppTheme.lightText),
                children: [
                  const TextSpan(text: 'Enter 4 digit code that you receive on your email ('),
                  TextSpan(
                    text: widget.email.isEmpty ? 'your@email.com' : widget.email,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: '). '),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (i) => OtpBox(controller: _cells[i])),
            ),
            const SizedBox(height: 10),
            Row(children: [
              const Text("Email not received?", style: TextStyle(color: AppTheme.lightText)),
              TextButton(onPressed: _resend, child: const Text('Resend code')),
            ]),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: !_submitting ? _continue : null,
              style: AppTheme.primaryButton(context),
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Continue'),
            ),
          ]),
        ),
      ),
    );
  }
}
