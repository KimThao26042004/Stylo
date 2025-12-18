import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import 'auth_common.dart';
import 'ResetPass_screen.dart';
import 'login_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  static const String routeName = '/verify';
  final String email;
  final String flow; // signup | forgot

  const VerificationCodeScreen({
    super.key,
    required this.email,
    required this.flow,
  });

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final _cells = List.generate(4, (_) => TextEditingController());
  // String get _code => _cells.map((c) => c.text).join();
  String _code = '';
  bool _submitting = false;
  String get _otp => _cells.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in _cells) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _continue() async {
    final otp = _otp;

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã OTP không hợp lệ')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final auth = context.read<AuthProvider>();

      if (widget.flow == 'forgot') {
        await auth.verifyResetOtp(
          email: widget.email,
          code: otp,
        );

        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          ResetPassScreen.routeName,
          arguments: widget.email,
        );
      } else {
        await auth.verifyOtp(
          email: widget.email,
          code: otp,
        );

        if (!mounted) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginScreen.routeName,
              (_) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xác thực thất bại')),
      );
    }

    setState(() => _submitting = false);
  }

  Future<void> _resend() async {
    final auth = context.read<AuthProvider>();
    final email = widget.email;

    // signup: resend-otp
    // reset: gọi lại forgot-password để gửi OTP reset mới
    if (widget.flow == "signup") {
      await auth.resendOtp(email);
    } else {
      await auth.forgotPassword(email);
    }

    if (!mounted) return;

    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error!)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resent code')));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

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
              TextButton(onPressed: auth.isLoading ? null : _resend, child: const Text('Resend code')),
            ]),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: auth.isLoading ? null : _continue,
              style: AppTheme.primaryButton(context),
              child: auth.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Continue'),
            ),
          ]),
        ),
      ),
    );
  }
}
