import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import 'auth_common.dart';
import 'ResetPass_screen.dart';
import 'login_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  static const String routeName = '/verify';
  final String email;
  final String flow;

  const VerificationCodeScreen({
    super.key,
    required this.email,
    required this.flow,
  });

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  // Tạo 4 controller cho 4 ô nhập OTP
  final List<TextEditingController> _cells = List.generate(4, (_) => TextEditingController());

  // Lấy giá trị OTP từ các ô nhập
  String get _otp => _cells.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in _cells) {
      c.dispose();
    }
    super.dispose();
  }

  // Hàm xử lý xác thực
  Future<void> _onVerify() async {
    final otp = _otp;

    if (otp.length != 4) {
      _showError('Vui lòng nhập đầy đủ mã xác thực');
      return;
    }

    final auth = context.read<AuthProvider>();

    // Thực hiện gọi API qua Provider
    if (widget.flow == 'forgot') {
      await auth.verifyResetOtp(email: widget.email, code: otp);
    } else {
      await auth.verifyOtp(email: widget.email, code: otp);
    }

    if (!mounted) return;

    // KIỂM TRA LỖI SAU KHI GỌI API
    if (auth.error != null) {
      _showError(auth.error!);
      return; // Dừng lại tại đây nếu có lỗi, không chuyển trang
    }

    // NẾU KHÔNG CÓ LỖI -> CHUYỂN TRANG
    if (widget.flow == 'forgot') {
      Navigator.pushReplacementNamed(
        context,
        ResetPassScreen.routeName,
        arguments: widget.email,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xác thực tài khoản thành công!'), backgroundColor: Colors.green),
      );
      Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (_) => false);
    }
  }

  // Hàm gửi lại mã
  Future<void> _onResend() async {
    final auth = context.read<AuthProvider>();

    if (widget.flow == "signup") {
      await auth.resendOtp(widget.email);
    } else {
      await auth.forgotPassword(widget.email);
    }

    if (!mounted) return;

    if (auth.error != null) {
      _showError(auth.error!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã mới đã được gửi vào Email'), backgroundColor: Colors.blue),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: const AppBackBar(title: 'Xác thực mã'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nhập mã xác nhận',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      text: 'Mã OTP đã được gửi đến ',
                      style: const TextStyle(color: AppTheme.lightText),
                      children: [
                        TextSpan(
                          text: widget.email,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(4, (i) => OtpBox(controller: _cells[i])),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _onVerify,
                              style: AppTheme.primaryButton(context),
                              child: isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Xác nhận'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Bạn chưa nhận được mã?"),
                              TextButton(
                                onPressed: isLoading ? null : _onResend,
                                child: const Text('Gửi lại', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
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