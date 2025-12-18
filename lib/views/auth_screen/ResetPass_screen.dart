import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';
import 'auth_common.dart';
import 'login_screen.dart';

class ResetPassScreen extends StatefulWidget {
  static const String routeName = '/reset';
  const ResetPassScreen({super.key});

  @override
  State<ResetPassScreen> createState() => _ResetPassScreenState();
}

class _ResetPassScreenState extends State<ResetPassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pass1 = TextEditingController();
  final _pass2 = TextEditingController();
  bool _ob1 = true, _ob2 = true;

  bool get _valid => _formKey.currentState?.validate() == true;

  @override
  void dispose() {
    _pass1.dispose();
    _pass2.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_valid) return;

    final auth = context.read<AuthProvider>();

    // lấy email từ arguments nếu có, không có thì lấy trong provider
    final argEmail = ModalRoute.of(context)?.settings.arguments as String?;
    final email = argEmail ?? auth.email ?? "";

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Missing email for reset password")),
      );
      return;
    }

    await auth.resetPassword(email, _pass1.text);

    if (!mounted) return;

    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated')),
    );
    Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: const AppBackBar(title: 'Reset Password'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Set the new password',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text(
              'Set the new password for your account so you can login and access all the features.',
              style: TextStyle(color: AppTheme.lightText),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              onChanged: () => setState(() {}),
              child: Column(children: [
                TextFormField(
                  controller: _pass1,
                  obscureText: _ob1,
                  decoration: AppTheme.input('Password', hint: '********').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_ob1 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _ob1 = !_ob1),
                    ),
                  ),
                  validator: passwordValidator,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _pass2,
                  obscureText: _ob2,
                  decoration: AppTheme.input('Password', hint: '********').copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_ob2 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _ob2 = !_ob2),
                    ),
                  ),
                  validator: (v) {
                    final base = passwordValidator(v);
                    if (base != null) return base;
                    if (v != _pass1.text) return 'Password does not match';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _valid && !auth.isLoading ? _continue : null,
                  style: AppTheme.primaryButton(context),
                  child: auth.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Continue'),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
