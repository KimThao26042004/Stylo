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

  // Kiểm tra tính hợp lệ của Form
  bool get _isValid => _formKey.currentState?.validate() ?? false;

  @override
  void dispose() {
    _pass1.dispose();
    _pass2.dispose();
    super.dispose();
  }

  // Hàm hiển thị thông báo (SnackBar) dùng chung cho cả Lỗi và Thành công
  void _showStatus(String message, {bool isError = true}) {
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
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
  }

  Future<void> _continue() async {
    if (!_isValid) return;

    final auth = context.read<AuthProvider>();
    final argEmail = ModalRoute.of(context)?.settings.arguments as String?;
    final email = argEmail ?? auth.email ?? "";

    if (email.isEmpty) {
      _showStatus("Không tìm thấy email để đặt lại mật khẩu", isError: true);
      return;
    }

    await auth.resetPassword(email, _pass1.text);

    if (!mounted) return;

    if (auth.error != null) {
      _showStatus(auth.error!, isError: true);
      return;
    }

    // Thông báo thành công
    _showStatus('Mật khẩu đã được cập nhật thành công!', isError: false);

    // Chờ 1.5 giây để người dùng thấy thông báo thành công trước khi về trang Login
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.routeName, (_) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const AppBackBar(title: 'Đặt lại mật khẩu'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thiết lập mật khẩu mới',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Vui lòng nhập mật khẩu mới cho tài khoản của bạn để hoàn tất quá trình khôi phục.',
                    style: TextStyle(color: AppTheme.lightText, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        onChanged: () {
                          // Xóa lỗi hệ thống và cập nhật trạng thái nút bấm khi đang gõ
                          if (auth.error != null) auth.clearError();
                          setState(() {});
                        },
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _pass1,
                              obscureText: _ob1,
                              onChanged: (_) => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                              decoration: AppTheme.input('Mật khẩu mới', hint: 'Ít nhất 6 ký tự').copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(_ob1 ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _ob1 = !_ob1),
                                ),
                              ),
                              validator: passwordValidator,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _pass2,
                              obscureText: _ob2,
                              onChanged: (_) => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                              decoration: AppTheme.input('Xác nhận mật khẩu', hint: 'Nhập lại mật khẩu mới').copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(_ob2 ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _ob2 = !_ob2),
                                ),
                              ),
                              validator: (v) => confirmPasswordValidator(v, _pass1.text),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: (_isValid && !auth.isLoading) ? _continue : null,
                                style: AppTheme.primaryButton(context),
                                child: auth.isLoading
                                    ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                                    : const Text(
                                  'Tiếp tục',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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