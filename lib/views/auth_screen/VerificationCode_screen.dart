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
  final List<TextEditingController> _cells = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  String get _otp => _cells.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in _cells) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _onVerify() async {
    final otp = _otp;

    if (otp.length != 4) {
      _showError('Vui lòng nhập đầy đủ mã xác thực');
      return;
    }

    final auth = context.read<AuthProvider>();

    if (widget.flow == 'forgot') {
      await auth.verifyResetOtp(email: widget.email, code: otp);
    } else {
      await auth.verifyOtp(email: widget.email, code: otp);
    }

    if (!mounted) return;

    if (auth.error != null) {
      _showError(auth.error!);
      return;
    }

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
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Mã mới đã được gửi vào Email'),
            ],
          ),
          backgroundColor: Colors.blue.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.grey.shade800, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Xác thực mã',
          style: TextStyle(
            color: Colors.grey.shade900,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// ===== ICON =====
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      color: Color(0xFFE53935),
                      size: 50,
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// ===== TITLE =====
                  Text(
                    'Xác thực tài khoản',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF212121),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Mã OTP đã được gửi đến\n',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 15,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: widget.email,
                          style: const TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// ===== OTP INPUT =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                          (i) => Padding(
                        padding: EdgeInsets.only(
                          left: i == 0 ? 0 : 8,
                          right: i == 3 ? 0 : 8,
                        ),
                        child: _buildOtpBox(i),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// ===== VERIFY BUTTON =====
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        elevation: 0,
                        shadowColor: const Color(0xFFE53935).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ).copyWith(
                        elevation: MaterialStateProperty.resolveWith<double>(
                              (states) {
                            if (states.contains(MaterialState.pressed)) return 0;
                            if (states.contains(MaterialState.disabled)) return 0;
                            return 2;
                          },
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        'Xác nhận',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// ===== RESEND =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Bạn chưa nhận được mã?",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: isLoading ? null : _onResend,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFE53935),
                        ),
                        child: const Text(
                          'Gửi lại',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// ===== INFO BOX =====
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: Colors.orange.shade700,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Mã OTP có hiệu lực trong 10 phút',
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontSize: 13,
                              height: 1.4,
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

  Widget _buildOtpBox(int index) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNodes[index].hasFocus
              ? const Color(0xFFE53935)
              : Colors.grey.shade300,
          width: _focusNodes[index].hasFocus ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: _cells[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF212121),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}