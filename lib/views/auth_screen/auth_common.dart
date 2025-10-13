import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Colors.black;
  static const Color lightText = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);

  static InputDecoration input(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black, width: 1.2),
    ),
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  static ButtonStyle primaryButton(BuildContext ctx) =>
      ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFCFD4DA),
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      );

  static ButtonStyle facebookButton(BuildContext ctx) =>
      ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1877F2),
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      );
}

// ------- Validators -------
String? emailValidator(String? v) {
  final s = v?.trim() ?? '';
  if (s.isEmpty) return 'Email is required';
  final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
  if (!ok) return 'Invalid email';
  return null;
}

String? passwordValidator(String? v) {
  final s = v ?? '';
  if (s.isEmpty) return 'Password is required';
  if (s.length < 6) return 'At least 6 characters';
  return null;
}

// ------- Small widgets -------
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(children: const [
      Expanded(child: Divider(color: AppTheme.divider)),
      SizedBox(width: 12),
      Text('Or'),
      SizedBox(width: 12),
      Expanded(child: Divider(color: AppTheme.divider)),
    ]);
  }
}

class TermsLine extends StatelessWidget {
  const TermsLine({super.key});
  @override
  Widget build(BuildContext context) {
    final style =
    Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.lightText, height: 1.4);
    return Text.rich(TextSpan(text: 'By signing up you agree to our ', style: style, children: const [
      TextSpan(text: 'Terms', style: TextStyle(decoration: TextDecoration.underline, color: Colors.black)),
      TextSpan(text: ', '),
      TextSpan(text: 'Privacy Policy', style: TextStyle(decoration: TextDecoration.underline, color: Colors.black)),
      TextSpan(text: ', and '),
      TextSpan(text: 'Cookie Use', style: TextStyle(decoration: TextDecoration.underline, color: Colors.black)),
    ]));
  }
}

class GoogleBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const GoogleBtn({super.key, required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: AppTheme.divider),
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      icon: const Icon(Icons.g_mobiledata, size: 28),
      label: Text(label),
    );
  }
}

class FacebookBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const FacebookBtn({super.key, required this.label, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: AppTheme.facebookButton(context),
      icon: const Icon(Icons.facebook),
      label: Text(label),
    );
  }
}

class AppBackBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const AppBackBar({super.key, required this.title});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      centerTitle: false,
      scrolledUnderElevation: 0,
    );
  }
}

class OtpBox extends StatelessWidget {
  final TextEditingController controller;
  const OtpBox({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onChanged: (v) {
          if (v.length == 1) FocusScope.of(context).nextFocus();
        },
      ),
    );
  }
}
