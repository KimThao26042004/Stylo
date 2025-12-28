// import 'package:flutter/material.dart';
// import '../auth_screen/auth_common.dart';
// import 'trackOrder_screen.dart';
//
// enum OrderStatus { packing, picked, inTransit, delivered }
//
// class OrderItemView {
//   final String name;
//   final String imageUrl;
//   final double price;
//   final String size;
//   OrderItemView({
//     required this.name,
//     required this.imageUrl,
//     required this.price,
//     this.size = 'M',
//   });
// }
//
// class OrderView {
//   final String id;
//   final OrderStatus status;
//   final List<OrderItemView> items;
//   OrderView({required this.id, required this.status, required this.items});
// }
//
// class Review {
//   final double rating;
//   final String comment;
//   const Review({required this.rating, required this.comment});
// }
//
// class MyOrdersScreen extends StatefulWidget {
//   const MyOrdersScreen({super.key});
//
//   @override
//   State<MyOrdersScreen> createState() => _MyOrdersScreenState();
// }
//
// class _MyOrdersScreenState extends State<MyOrdersScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tab;
//
//   // --- Mock data (sau này thay bằng API .NET) ---
//   final List<OrderView> _ongoing = [
//     OrderView(id: 'ORD-001', status: OrderStatus.inTransit, items: [
//       OrderItemView(
//         name: 'Regular Fit Slogan',
//         imageUrl: 'https://picsum.photos/seed/a/400/400',
//         price: 1190,
//       )
//     ]),
//     OrderView(id: 'ORD-002', status: OrderStatus.picked, items: [
//       OrderItemView(
//         name: 'Regular Fit Polo',
//         imageUrl: 'https://picsum.photos/seed/b/400/400',
//         price: 1100,
//       )
//     ]),
//     OrderView(id: 'ORD-003', status: OrderStatus.packing, items: [
//       OrderItemView(
//         name: 'Regular Fit Black',
//         imageUrl: 'https://picsum.photos/seed/c/400/400',
//         price: 1690,
//       )
//     ]),
//   ];
//
//   final List<OrderView> _completed = [
//     OrderView(id: 'ORD-100', status: OrderStatus.delivered, items: [
//       OrderItemView(
//         name: 'Regular Fit Slogan',
//         imageUrl: 'https://picsum.photos/seed/d/400/400',
//         price: 1190,
//       )
//     ]),
//     OrderView(id: 'ORD-101', status: OrderStatus.delivered, items: [
//       OrderItemView(
//         name: 'Regular Fit Polo',
//         imageUrl: 'https://picsum.photos/seed/e/400/400',
//         price: 1100,
//       )
//     ]),
//   ];
//
//   /// Lưu review theo orderId
//   final Map<String, Review> _reviews = {
//     'ORD-101': const Review(rating: 4.5, comment: 'Good quality!')
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _tab = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tab.dispose();
//     super.dispose();
//   }
//
//   Future<void> _openReviewSheet(OrderView order) async {
//     final current = _reviews[order.id];
//     final result = await showModalBottomSheet<Review>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
//       ),
//       builder: (_) => _ReviewSheet(initial: current),
//     );
//     if (result != null) {
//       setState(() => _reviews[order.id] = result);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const AppBackBar(title: 'My Orders'),
//       body: Column(
//         children: [
//           const SizedBox(height: 8),
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 12),
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade200,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: TabBar(
//               controller: _tab,
//               indicator: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               labelColor: Colors.black,
//               unselectedLabelColor: Colors.black54,
//               tabs: const [Tab(text: 'Ongoing'), Tab(text: 'Completed')],
//             ),
//           ),
//           Expanded(
//             child: TabBarView(
//               controller: _tab,
//               children: [
//                 // Ongoing
//                 _ongoing.isEmpty
//                     ? const _EmptyOrders(text: 'No Ongoing Orders!')
//                     : _OngoingList(orders: _ongoing),
//                 // Completed
//                 _CompletedList(
//                   orders: _completed,
//                   reviews: _reviews,
//                   onLeaveReview: _openReviewSheet,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// /* ======================= Ongoing tab ======================= */
// class _OngoingList extends StatelessWidget {
//   final List<OrderView> orders;
//   const _OngoingList({required this.orders});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(12),
//       itemCount: orders.length,
//       itemBuilder: (_, i) {
//         final order = orders[i];
//         final item = order.items.first;
//         return Container(
//           margin: const EdgeInsets.symmetric(vertical: 6),
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: Row(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.network(item.imageUrl, width: 72, height: 72, fit: BoxFit.cover),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
//                   Text('Size ${item.size}', style: TextStyle(color: Colors.grey.shade600)),
//                   const SizedBox(height: 4),
//                   Text('\$ ${item.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.w700)),
//                 ]),
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   _statusPill(order.status),
//                   const SizedBox(height: 6),
//                   OutlinedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => TrackOrderScreen(order: order)),
//                       );
//                     },
//                     style: OutlinedButton.styleFrom(minimumSize: const Size(110, 38)),
//                     child: const Text('Track Order'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// Widget _statusPill(OrderStatus s) {
//   final text = switch (s) {
//     OrderStatus.packing => 'Packing',
//     OrderStatus.picked => 'Picked',
//     OrderStatus.inTransit => 'In Transit',
//     OrderStatus.delivered => 'Delivered',
//   };
//   return Container(
//     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//     decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
//     child: Text(text, style: const TextStyle(color: Colors.white)),
//   );
// }
//
// /* ======================= Completed tab ======================= */
// class _CompletedList extends StatelessWidget {
//   final List<OrderView> orders;
//   final Map<String, Review> reviews;
//   final void Function(OrderView order) onLeaveReview;
//
//   const _CompletedList({
//     required this.orders,
//     required this.reviews,
//     required this.onLeaveReview,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (orders.isEmpty) return const _EmptyOrders(text: 'No Completed Orders!');
//     return ListView.builder(
//       padding: const EdgeInsets.all(12),
//       itemCount: orders.length,
//       itemBuilder: (_, i) {
//         final order = orders[i];
//         final item = order.items.first;
//         final review = reviews[order.id];
//         return Container(
//           margin: const EdgeInsets.symmetric(vertical: 6),
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: Row(
//             children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.network(item.imageUrl, width: 72, height: 72, fit: BoxFit.cover),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
//                   Text('Size ${item.size}', style: TextStyle(color: Colors.grey.shade600)),
//                   const SizedBox(height: 4),
//                   Text('\$ ${item.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.w700)),
//                 ]),
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.green.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.green),
//                     ),
//                     child: const Text('Completed', style: TextStyle(color: Colors.green)),
//                   ),
//                   const SizedBox(height: 6),
//                   review == null
//                       ? ElevatedButton(
//                     onPressed: () => onLeaveReview(order),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       foregroundColor: Colors.white,
//                       minimumSize: const Size(120, 38),
//                     ),
//                     child: const Text('Leave Review'),
//                   )
//                       : _RatingChip(rating: review.rating),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _RatingChip extends StatelessWidget {
//   final double rating;
//   const _RatingChip({required this.rating});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 38,
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.amber),
//         color: Colors.amber.shade50,
//       ),
//       alignment: Alignment.center,
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         const Icon(Icons.star, size: 16, color: Colors.amber),
//         const SizedBox(width: 4),
//         Text('${rating.toStringAsFixed(1)}/5',
//             style: const TextStyle(fontWeight: FontWeight.w600)),
//       ]),
//     );
//   }
// }
//
// /* ======================= Empty-state ======================= */
// class _EmptyOrders extends StatelessWidget {
//   final String text;
//   const _EmptyOrders({required this.text});
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         const Divider(height: 1),
//         Expanded(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.inventory_2_outlined,
//                     size: 56, color: AppTheme.lightText),
//                 const SizedBox(height: 12),
//                 Text(text,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.w700, fontSize: 16)),
//                 const SizedBox(height: 6),
//                 const Text("You don't have any orders at this time.",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: AppTheme.lightText)),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// /* ======================= BottomSheet Review ======================= */
// class _ReviewSheet extends StatefulWidget {
//   final Review? initial;
//   const _ReviewSheet({this.initial});
//
//   @override
//   State<_ReviewSheet> createState() => _ReviewSheetState();
// }
//
// class _ReviewSheetState extends State<_ReviewSheet> {
//   late double _rating; // 1..5 (0.5 step)
//   late TextEditingController _ctrl;
//
//   @override
//   void initState() {
//     super.initState();
//     _rating = widget.initial?.rating ?? 5.0;
//     _ctrl = TextEditingController(text: widget.initial?.comment ?? '');
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bottomInset = MediaQuery.of(context).viewInsets.bottom;
//     return Padding(
//       padding: EdgeInsets.only(bottom: bottomInset),
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 44,
//                   height: 4,
//                   decoration: BoxDecoration(
//                       color: Colors.grey.shade400,
//                       borderRadius: BorderRadius.circular(2)),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   const Expanded(
//                     child: Text('Leave a Review',
//                         style: TextStyle(
//                             fontWeight: FontWeight.w700, fontSize: 16)),
//                   ),
//                   IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: const Icon(Icons.close)),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               const Text('How was your order?',
//                   style: TextStyle(fontWeight: FontWeight.w600)),
//               const SizedBox(height: 4),
//               const Text('Please give your rating and also your review.',
//                   style: TextStyle(color: AppTheme.lightText)),
//               const SizedBox(height: 12),
//
//               Center(child: _Stars(rating: _rating, onRate: (v) => setState(() => _rating = v))),
//               const SizedBox(height: 8),
//               Slider(
//                 min: 1,
//                 max: 5,
//                 divisions: 8,
//                 value: _rating,
//                 label: _rating.toStringAsFixed(1),
//                 onChanged: (v) => setState(() => _rating = v),
//               ),
//               const SizedBox(height: 8),
//
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 padding: const EdgeInsets.all(12),
//                 child: TextField(
//                   controller: _ctrl,
//                   maxLines: 5,
//                   decoration: const InputDecoration.collapsed(
//                       hintText: 'Write your review...'),
//                 ),
//               ),
//               const SizedBox(height: 14),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     foregroundColor: Colors.white,
//                     minimumSize: const Size.fromHeight(48),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                   ),
//                   onPressed: () {
//                     Navigator.pop(
//                       context,
//                       Review(rating: _rating, comment: _ctrl.text.trim()),
//                     );
//                   },
//                   child: const Text('Submit'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _Stars extends StatelessWidget {
//   final double rating; // 1..5
//   final ValueChanged<double> onRate;
//   const _Stars({required this.rating, required this.onRate});
//
//   @override
//   Widget build(BuildContext context) {
//     final widgets = <Widget>[];
//     for (int i = 1; i <= 5; i++) {
//       final full = rating >= i;
//       final half = !full && rating >= (i - 0.5);
//       widgets.add(
//         InkWell(
//           onTap: () => onRate(i.toDouble()),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 4),
//             child: Icon(
//               full ? Icons.star : (half ? Icons.star_half : Icons.star_border),
//               size: 32,
//               color: Colors.amber,
//             ),
//           ),
//         ),
//       );
//     }
//     return Row(mainAxisAlignment: MainAxisAlignment.center, children: widgets);
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_history_model.dart';
import '../../state/auth_provider.dart';
import '../../state/order_provider.dart';
import '../auth_screen/auth_common.dart';
import 'trackOrder_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

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
                    Text('Size ${item.size}', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('\$ ${item.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusPill(status: order.statusEnum), // Gọi Class Pill
                  const SizedBox(height: 6),
                  OutlinedButton(
                    onPressed: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => TrackOrderScreen(order: order)));
                    },
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