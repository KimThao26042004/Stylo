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
  late DateTime _currentDate; // Ngày khách mở màn hình thanh toán
  late DateTime _estimatedDate; // Ngày dự kiến giao hàng

  @override
  void initState() {
    super.initState();
    // Khởi tạo ngay khi vào màn hình
    _currentDate = DateTime.now();
    _estimatedDate = _currentDate.add(const Duration(days: 3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAddresses();
    });
  }

  DateTime get _deliveryDate =>
      DateTime.now().add(const Duration(days: 3));

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final account = context.watch<AccountProvider>();

    final subTotal = cart.subTotal;
    final total = subTotal + _shippingFee + _vat;

    final defaultAddress =
    account.addresses.where((a) => a.isDefault).toList();

    return Scaffold(
      appBar: const AppBackBar(title: 'Checkout'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /* ================= DELIVERY ADDRESS ================= */
          _sectionTitle('Delivery Address'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (account.isLoading)
                      const Text('Loading address...')
                    else if (defaultAddress.isEmpty)
                      const Text(
                        'Chưa có địa chỉ mặc định',
                        style: TextStyle(color: Colors.red),
                      )
                    else
                      Text(
                        '${defaultAddress.first.loaiDiaChi}: ${defaultAddress.first.diaChiChiTiet}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    TextButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddressScreen(),
                          ),
                        );
                        if (!mounted) return;
                        context.read<AccountProvider>().loadAddresses();
                      },
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 32),

          /* ================= DELIVERY DATE ================= */
          _sectionTitle('Estimated Delivery'),
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Date: ${DateFormat('dd/MM/yyyy').format(_currentDate)}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "Estimated: ${DateFormat('dd/MM/yyyy').format(_estimatedDate)}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),

          const Divider(height: 32),

          /* ================= PAYMENT METHOD ================= */
          _sectionTitle('Payment Method'),
          _paymentTile(PaymentMethod.card, Icons.credit_card, 'Card'),
          _paymentTile(PaymentMethod.cash, Icons.payments_outlined, 'Cash on Delivery'),
          _paymentTile(PaymentMethod.applePay, Icons.apple, 'Apple Pay'),

          const Divider(height: 32),

          /* ================= ORDER SUMMARY ================= */
          _sectionTitle('Order Summary'),
          _row('Sub-total', subTotal),
          _row('VAT (%)', _vat),
          _row('Shipping fee', _shippingFee),
          const Divider(),
          _row('Total', total, bold: true),

          const SizedBox(height: 20),

          /* ================= PLACE ORDER ================= */
          ElevatedButton(
            style: AppTheme.primaryButton(context),
            onPressed: defaultAddress.isEmpty || cart.items.isEmpty || cart.isProcessing
                ? null
                : () async {
              try {
                final auth = context.read<AuthProvider>();

                // Đảm bảo lấy ID từ đúng nguồn đã đăng nhập
                // Nếu auth.khachHangId chưa được set, thử parse từ userId (nếu userId là số)
                int khId = auth.khachHangId ?? int.tryParse(auth.userId ?? '0') ?? 0;

                if (khId <= 0) {
                  throw Exception("Vui lòng đăng nhập lại để xác thực thông tin khách hàng.");
                }

                // Thực hiện gọi hàm đặt hàng
                final orderId = await context.read<CartProvider>().processOrder(
                  khachHangId: khId,
                  shippingFee: _shippingFee,
                );

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đặt hàng thành công! Mã đơn: #$orderId'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Xóa lịch sử và về trang đơn hàng
                // Xóa mọi thứ và về HomeScreen trước, sau đó mới đẩy MyOrdersScreen lên
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()), // Về trang chủ
                      (route) => false,
                );

                // Sau khi về Home, đẩy trang MyOrders lên để người dùng xem,
                // khi bấm back sẽ về lại Home/Account
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                );
              } catch (e) {
                if (!context.mounted) return;

                showDialog(
                  context: context,
                  barrierDismissible: false, // Ngăn người dùng tắt dialog bằng cách chạm ra ngoài
                  builder: (_) => AlertDialog(
                    title: const Text('Thông báo'),
                    content: Text(e.toString().replaceAll("Exception: ", "")),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Đóng Dialog
                          Navigator.pop(context); // Quay lại trang CartScreen để khách sửa số lượng
                        },
                        child: const Text('Quay lại giỏ hàng'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: cart.isProcessing
                ? const SizedBox(
              height: 20, width: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : const Text('Place Order'),
          ),
        ],
      ),
    );
  }

  /* ================= UI HELPERS ================= */

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    ),
  );

  Widget _row(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '${value.toStringAsFixed(0)} đ',
            style: TextStyle(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentTile(
      PaymentMethod value,
      IconData icon,
      String label,
      ) {
    return RadioListTile<PaymentMethod>(
      value: value,
      groupValue: _payment,
      onChanged: (v) => setState(() => _payment = v!),
      title: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
