import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_history_model.dart';
import '../../state/auth_provider.dart';
import '../../state/cart_provider.dart';
import '../../state/order_provider.dart';
import '../auth_screen/auth_common.dart';
import '../cart_screen/cart_screen.dart';
import '../products_screen/productDetail_screen.dart';
import 'orderDetail_screen.dart';
import 'trackOrder_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
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

        // Bọc bằng GestureDetector để bắt sự kiện click toàn bộ Card
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailScreen(order: order),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER: Mã đơn và Trạng thái
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Order #${order.id}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    _StatusPill(status: order.statusEnum),
                  ],
                ),
                const Divider(),

                // HIỂN THỊ TẤT CẢ SẢN PHẨM
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 72,
                                height: 72,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image,
                                    color: Colors.grey),
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text('Size ${item.size} | Qty: ${item.quantity}',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text('\$ ${item.price.toInt()}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
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
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    OutlinedButton(
                      onPressed: () {
                        // Nút Track Order vẫn giữ chức năng chuyển đến bản đồ
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TrackOrderScreen(order: order),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(110, 38)),
                      child: const Text('Track Order'),
                    ),
                  ],
                ),
              ],
            ),
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

  // Hàm xử lý logic mua lại
  void _handleReorder(BuildContext context, OrderHistoryModel order) {
    if (order.items.length == 1) {
      // TH1: Chỉ có 1 sản phẩm -> Chuyển thẳng tới trang chi tiết
      _processReorderItem(context, order.items.first);
    } else {
      // TH2: Nhiều sản phẩm -> Hiển thị lựa chọn
      _showProductSelectionSheet(context, order.items);
    }
  }

  // Hàm điều hướng (Thay ProductDetailScreen bằng tên Class thật của bạn)
  void _processReorderItem(BuildContext context, OrderItemModel item) {
    if (item.bienTheId != 0) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Gọi hàm add của CartProvider với đầy đủ thông số
      cartProvider.addFromReorder(
        bienTheId: item.bienTheId,
        sanPhamId: item.sanPhamId, // Dùng để quay lại trang detail nếu cần
        productName: item.name,
        imageUrl: item.imageUrl,
        price: item.price.toInt(),
        sizeId: item.sizeId,
        sizeName: item.size,
        colorId: item.mauSac['id'] ?? 0,
        colorName: item.mauSac['ten'] ?? 'N/A',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã thêm ${item.name} vào giỏ hàng")),
      );

      // Điều hướng sang trang giỏ hàng
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CartScreen()),
      );
    }
  }

  // Modal chọn sản phẩm khi đơn hàng có nhiều món
  void _showProductSelectionSheet(BuildContext context, List<OrderItemModel> items) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Chọn sản phẩm muốn mua lại",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: Image.network(item.imageUrl, width: 40, errorBuilder: (_,__,___)=> const Icon(Icons.image)),
                      title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text("Size: ${item.size} - \$${item.price.toInt()}"),
                      onTap: () {
                        Navigator.pop(context);
                        _processReorderItem(context, item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (_, i) {
        final order = orders[i];

        return GestureDetector(
          onTap: () {
            // Chuyển hướng sang màn hình Chi tiết đơn hàng khi click vào Card
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailScreen(order: order),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
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

                // HIỂN THỊ TẤT CẢ SẢN PHẨM
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
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
                            Text(item.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
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
                // FOOTER: Tổng tiền bên trái - Các nút nằm gọn bên phải (Đã đồng bộ kích thước)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // TỔNG TIỀN
                    Text(
                      "Total: \$${order.tongThanhToan.toInt()}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),

                    // CỤM NÚT (BÊN PHẢI)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Nút Review - Outlined giống Track Order nhưng kích thước đồng bộ
                        OutlinedButton(
                          onPressed: () => onLeaveReview(order),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(100, 38), // Chiều cao 38 giống Ongoing
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                          child: const Text(
                            'Review',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Nút Re-order - Elevated để tạo điểm nhấn nhưng vẫn cao 38
                        ElevatedButton(
                          onPressed: () => _handleReorder(context, order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(100, 38), // Chiều cao 38 giống Ongoing
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            elevation: 0, // Để phẳng nếu muốn giao diện tối giản
                          ),
                          child: const Text('Re-order'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductItem(OrderItemModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(item.imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                errorBuilder: (_,__,___) => Container(width: 60, height: 60, color: Colors.grey[100])),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('Size ${item.size} | Qty: ${item.quantity}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final OrderStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    // Mapping màu sắc và tên hiển thị
    Color color = Colors.orange;
    String label = "Processing";

    switch (status) {
      case OrderStatus.created:
        color = Colors.blue;
        label = "Created";
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        label = "Delivered";
        break;
      case OrderStatus.inTransit:
        color = Colors.purple;
        label = "Shipping";
        break;
      default:
        color = Colors.black;
        label = status.name.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8)
      ),
      child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
      ),
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