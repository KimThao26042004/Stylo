import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_history_model.dart';
import '../auth_screen/auth_common.dart';
import 'trackOrder_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderHistoryModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy, HH:mm');
    final currencyFormat = NumberFormat("#,##0", "vi_VN");

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBackBar(title: 'Chi tiết đơn hàng #${order.id}'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Trạng thái và Ngày đặt
            _buildSection(
              child: Column(
                children: [
                  _buildInfoRow('Ngày đặt', df.format(order.ngayDat)),
                  const Divider(),
                  _buildInfoRow('Trạng thái', order.trangThaiGiao.toUpperCase(),
                      valueColor: Colors.blue, isBold: true),
                  if (order.maVanDon != null) ...[
                    const Divider(),
                    _buildInfoRow('Mã vận đơn', order.maVanDon!),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            // 2. Danh sách sản phẩm
            _buildSection(
              padding: EdgeInsets.zero,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(item.imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[200]),
                      ),
                    ),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('Kích cỡ: ${item.size} | Số lượng: ${item.quantity}'),
                    trailing: Text('${currencyFormat.format(item.price)} đ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            const Text('Tóm tắt thanh toán', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            // 3. Tổng kết tiền bạc
            _buildSection(
              child: Column(
                children: [
                  // SỬA TẠI ĐÂY: Các dòng tóm tắt tiền bạc
                  _buildInfoRow('Tổng phụ', '${currencyFormat.format(_calculateSubtotal())} đ'),
                  _buildInfoRow('Phí vận chuyển', '30.000 đ'),
                  _buildInfoRow('Giảm giá', '-0 đ'),
                  const Divider(),
                  _buildInfoRow('Tổng thanh toán', '${currencyFormat.format(order.tongThanhToan)} đ',
                      isBold: true, fontSize: 18, valueColor: Colors.black),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 4. Nút bấm hành động
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TrackOrderScreen(order: order)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Theo dõi đơn hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateSubtotal() {
    return order.items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  Widget _buildSection({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, bool isBold = false, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? Colors.black,
            fontSize: fontSize,
          )),
        ],
      ),
    );
  }
}