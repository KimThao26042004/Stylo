import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../state/account_provider.dart';
import '../../state/auth_provider.dart';
import '../../state/cart_provider.dart';
import '../auth_screen/auth_common.dart';
import '../cart_screen/address_screen.dart';
import '../home_screen/home_screen.dart';
import '../order_screen/myOrders_screen.dart';

enum PaymentMethod { card, cash, applePay }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const double _shippingFee = 30000;
  static const double _vat = 0;

  PaymentMethod _payment = PaymentMethod.cash;
  late DateTime _currentDate;
  late DateTime _estimatedDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _estimatedDate = _currentDate.add(const Duration(days: 3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAddresses();
    });
  }

  // --- HÀM THÔNG BÁO CHUẨN ---
  void _showStatusMessage(String message, {bool isError = true, IconData? icon}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon ?? (isError ? Icons.error_outline : Icons.check_circle_outline),
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.redAccent : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final account = context.watch<AccountProvider>();

    final subTotal = cart.subTotal;
    final total = subTotal + _shippingFee + _vat;

    final defaultAddress = account.addresses.where((a) => a.isDefault).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Nền xám nhẹ cho sang trọng
      appBar: const AppBackBar(title: 'Thanh toán'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /* ================= DELIVERY ADDRESS ================= */
          _sectionTitle('Địa chỉ giao hàng'),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Color(0xFFE53935)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (account.isLoading)
                        const Text('Đang tải địa chỉ...')
                      else if (defaultAddress.isEmpty)
                        const Text('Chưa có địa chỉ mặc định', style: TextStyle(color: Colors.red))
                      else ...[
                          Text(
                            defaultAddress.first.loaiDiaChi,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            defaultAddress.first.diaChiChiTiet,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddressScreen()),
                            );
                            if (!mounted) return;
                            context.read<AccountProvider>().loadAddresses();
                          },
                          child: const Text('Thay đổi'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /* ================= DELIVERY DATE ================= */
          _sectionTitle('Thời gian giao hàng dự kiến'),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_outlined, color: Colors.blue),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ngày đặt: ${DateFormat('dd/MM/yyyy').format(_currentDate)}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      "Dự kiến giao: ${DateFormat('dd/MM/yyyy').format(_estimatedDate)}",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /* ================= PAYMENT METHOD ================= */
          _sectionTitle('Phương thức thanh toán'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _paymentTile(PaymentMethod.card, Icons.credit_card, 'Thẻ Tín dụng / Ghi nợ'),
                const Divider(height: 1, indent: 50),
                _paymentTile(PaymentMethod.cash, Icons.payments_outlined, 'Thanh toán khi nhận hàng (COD)'),
                const Divider(height: 1, indent: 50),
                _paymentTile(PaymentMethod.applePay, Icons.apple, 'Apple Pay'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /* ================= ORDER SUMMARY ================= */
          _sectionTitle('Tóm tắt đơn hàng'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _row('Tổng phụ', subTotal),
                _row('VAT (%)', _vat),
                _row('Phí vận chuyển', _shippingFee),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(),
                ),
                _row('Tổng cộng', total, bold: true, color: const Color(0xFFE53935)),
              ],
            ),
          ),

          const SizedBox(height: 32),

          /* ================= PLACE ORDER ================= */
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: AppTheme.primaryButton(context),
              onPressed: defaultAddress.isEmpty || cart.items.isEmpty || cart.isProcessing
                  ? null
                  : () async {
                try {
                  final auth = context.read<AuthProvider>();
                  int khId = auth.khachHangId ?? int.tryParse(auth.userId ?? '0') ?? 0;

                  if (khId <= 0) {
                    throw Exception("Vui lòng đăng nhập lại để xác thực.");
                  }

                  final orderId = await context.read<CartProvider>().processOrder(
                    khachHangId: khId,
                    shippingFee: _shippingFee,
                  );

                  if (!mounted) return;

                  // THÔNG BÁO THÀNH CÔNG ĐẸP
                  _showStatusMessage(
                    'Đặt hàng thành công! Mã đơn: #$orderId',
                    isError: false,
                    icon: Icons.verified_rounded,
                  );

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                  );
                } catch (e) {
                  if (!mounted) return;
                  // THÔNG BÁO LỖI QUA SNACKBAR (Thay vì Dialog cứng nhắc)
                  _showStatusMessage(e.toString().replaceAll("Exception: ", ""));
                }
              },
              child: cart.isProcessing
                  ? const SizedBox(
                height: 24, width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text('ĐẶT HÀNG NGAY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /* ================= UI HELPERS ================= */

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(
      title.toUpperCase(),
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 13,
        color: Colors.grey.shade600,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _row(String label, double value, {bool bold = false, Color? color}) {
    final format = NumberFormat("#,##0", "vi_VN");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: bold ? Colors.black : Colors.grey.shade700)),
          Text(
            '${format.format(value)} đ',
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              fontSize: bold ? 18 : 14,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentTile(PaymentMethod value, IconData icon, String label) {
    return RadioListTile<PaymentMethod>(
      value: value,
      groupValue: _payment,
      activeColor: const Color(0xFFE53935),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      onChanged: (v) => setState(() => _payment = v!),
      title: Row(
        children: [
          Icon(icon, size: 22, color: Colors.grey.shade700),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}