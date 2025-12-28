import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_history_model.dart';
import '../../state/auth_provider.dart';
import '../../state/order_provider.dart';
import '../auth_screen/auth_common.dart';
import 'trackOrder_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  OrderStatus get status => OrderStatus.packing; // "CREATED";

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.token != null) {
        context.read<OrderProvider>().fetchOrders(auth.token!);
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _openReviewSheet(OrderHistoryModel order) async {
    // Logic để mở BottomSheet review của bạn
    debugPrint("Mở review cho đơn hàng: ${order.id}");
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: const AppBackBar(title: 'My Orders'),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildTabBar(),
          Expanded(
            child: orderProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : TabBarView(
              controller: _tab,
              children: [
                orderProvider.ongoingOrders.isEmpty
                    ? const _EmptyOrders(text: 'No Ongoing Orders!')
                    : _OngoingList(orders: orderProvider.ongoingOrders),
                orderProvider.completedOrders.isEmpty
                    ? const _EmptyOrders(text: 'No Completed Orders!')
                    : _CompletedList(
                  orders: orderProvider.completedOrders,
                  reviews: const {},
                  onLeaveReview: _openReviewSheet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tab,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black54,
        tabs: const [Tab(text: 'Ongoing'), Tab(text: 'Completed')],
      ),
    );
  }
}

/* ======================= Tách các Widget thành Class để sửa lỗi defined ======================= */

class _OngoingList extends StatelessWidget {
  final List<OrderHistoryModel> orders;
  const _OngoingList({required this.orders});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (_, i) {
        final order = orders[i];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER: Mã đơn và Trạng thái
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Order #${order.id}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  _StatusPill(status: order.statusEnum),
                ],
              ),
              const Divider(),

              // HIỂN THỊ TẤT CẢ SẢN PHẨM (Sửa lỗi mất ID 205)
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      // DÙNG CÁCH LOAD ẢNH CŨ CỦA BẠN (Không nối serverUrl thủ công nữa)
                      child: Image.network(
                        item.imageUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        // Thêm errorBuilder để tránh sập UI nếu server lỗi file
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 72, height: 72, color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('Size ${item.size} | Qty: ${item.quantity}',
                              style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('\$ ${item.price.toInt()}',
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),

              const Divider(),
              // FOOTER: Tổng thanh toán đơn hàng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total: \$${order.tongThanhToan.toInt()}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(minimumSize: const Size(110, 38)),
                    child: const Text('Track Order'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompletedList extends StatelessWidget {
  final List<OrderHistoryModel> orders;
  final Map<String, dynamic> reviews;
  final Function(OrderHistoryModel) onLeaveReview;

  const _CompletedList({
    required this.orders,
    required this.reviews,
    required this.onLeaveReview,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (_, i) {
        final order = orders[i];
        final item = order.items.first;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(item.imageUrl, width: 72, height: 72, fit: BoxFit.cover),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('\$ ${item.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => onLeaveReview(order),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                child: const Text('Review'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  final OrderStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    String text = status.name.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  final String text;
  const _EmptyOrders({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}