import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/order_history_model.dart';
import '../auth_screen/auth_common.dart';

class TrackOrderScreen extends StatelessWidget {
  // Thay đổi: Nhận vào OrderHistoryModel thay vì MyOrdersScreen
  final OrderHistoryModel order;

  final LatLng target = const LatLng(21.0285, 105.8399);
  final List<LatLng> route = const [
    LatLng(21.0285, 105.8399),
    LatLng(21.0300, 105.8420),
    LatLng(21.0320, 105.8450),
  ];

  const TrackOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBackBar(title: 'Track Order #${order.id}'),
      body: Stack(
        children: [
          _OrderMap(center: target, route: route),
          Align(
            alignment: Alignment.bottomCenter,
            child: _OrderStatusSheet(
              // Truyền status thực tế từ model
              status: order.statusEnum,
              courier: 'Jacob Jones',
              maVanDon: order.maVanDon ?? "Chưa có mã",
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderMap extends StatelessWidget {
  final LatLng center;
  final List<LatLng> route;

  const _OrderMap({required this.center, required this.route});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13,
      ),
      children: [
        // Lớp bản đồ nền OSM (không cần token)
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.example.fashion_shop', // đổi theo package thật
        ),

        // Vẽ đường đi (polyline)
        if (route.length >= 2)
          PolylineLayer(polylines: [
            Polyline(points: route, strokeWidth: 4, color: Colors.blue),
          ]),

        // Marker đích (target)
        MarkerLayer(markers: [
          Marker(
            point: center,
            width: 40,
            height: 40,
            child: const Icon(Icons.location_on, color: Colors.red, size: 36),
          ),
        ]),
      ],
    );
  }
}

class _OrderStatusSheet extends StatelessWidget {
  final OrderStatus status;
  final String courier;
  final String maVanDon;

  const _OrderStatusSheet({
    required this.status,
    required this.courier,
    required this.maVanDon
  });

  @override
  Widget build(BuildContext context) {
    // Định nghĩa các bước hiển thị trên giao diện
    final steps = ['Created', 'Picked', 'Shipping', 'Delivered'];

    // Ánh xạ trạng thái thực tế sang vị trí index (0 -> 3)
    int currentStep = 0;
    switch (status) {
      case OrderStatus.created: currentStep = 0; break;
      case OrderStatus.picked: currentStep = 1; break;
      case OrderStatus.inTransit: currentStep = 2; break;
      case OrderStatus.delivered: currentStep = 3; break;
      case OrderStatus.failed: currentStep = -1; break; // Xử lý lỗi nếu cần
      case OrderStatus.returned: currentStep = -1; break;
    }

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Order Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Waybill: $maVanDon', style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),

          // Danh sách các bước trạng thái
          ...List.generate(steps.length, (i) {
            final isCompleted = i < currentStep;
            final isCurrent = i == currentStep;
            final active = isCompleted || isCurrent;

            return IntrinsicHeight(
              child: Row(
                children: [
                  Column(
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : (isCurrent ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                        size: 22,
                        color: active ? Colors.black : Colors.grey[300],
                      ),
                      if (i < steps.length - 1)
                        Expanded(
                          child: VerticalDivider(
                            color: i < currentStep ? Colors.black : Colors.grey[300],
                            thickness: 2,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[i],
                          style: TextStyle(
                            fontWeight: active ? FontWeight.bold : FontWeight.normal,
                            color: active ? Colors.black : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20), // Tạo khoảng cách giữa các dòng
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const Divider(),
          const SizedBox(height: 10),
          Row(
            children: [
              const CircleAvatar(backgroundColor: Colors.black, child: Icon(Icons.delivery_dining, color: Colors.white)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(courier, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Shipper', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const Spacer(),
              _ActionIcon(icon: Icons.call),
              const SizedBox(width: 8),
              _ActionIcon(icon: Icons.chat_bubble_outline),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  const _ActionIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
      child: Icon(icon, size: 20),
    );
  }
}