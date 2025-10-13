import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../auth_screen/auth_common.dart';
import 'myOrders_screen.dart';

class TrackOrderScreen extends StatelessWidget {
  final OrderView order;

  /// toạ độ demo – sau này bạn thay bằng dữ liệu thật từ backend
  final LatLng target = const LatLng(21.0285, 105.8399);

  /// đường đi demo – thay bằng route thật từ API .NET (nếu có)
  final List<LatLng> route = const [
    LatLng(21.0285, 105.8399),
    LatLng(21.0300, 105.8420),
    LatLng(21.0320, 105.8450),
  ];

  const TrackOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBackBar(title: 'Track Order'),
      body: Stack(
        children: [
          _OrderMap(center: target, route: route),
          Align(
            alignment: Alignment.bottomCenter,
            child: _OrderStatusSheet(
              status: order.status,
              courier: 'Jacob Jones',
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

/// Bottom sheet hiển thị trạng thái đơn hàng
class _OrderStatusSheet extends StatelessWidget {
  final OrderStatus status;
  final String courier;
  const _OrderStatusSheet({required this.status, required this.courier});

  @override
  Widget build(BuildContext context) {
    final steps = ['Packing', 'Picked', 'In Transit', 'Delivered'];
    final current = switch (status) {
      OrderStatus.packing => 0,
      OrderStatus.picked => 1,
      OrderStatus.inTransit => 2,
      OrderStatus.delivered => 3,
    };

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Order Status', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...List.generate(steps.length, (i) {
            final active = i <= current;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  active ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: 20,
                  color: active ? Colors.black : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[i],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.black : Colors.grey,
                        ),
                      ),
                      if (i < steps.length - 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Container(height: 12, width: 2, color: Colors.grey.shade300),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person_outline)),
              const SizedBox(width: 8),
              Text(courier, style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.message_outlined)),
            ],
          ),
        ],
      ),
    );
  }
}
