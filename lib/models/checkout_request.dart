class CheckoutRequest {
  final int khachHangId;
  final String kenhBan;
  final double phiVanChuyen;
  final List<CheckoutItem> items;

  CheckoutRequest({
    required this.khachHangId,
    this.kenhBan = "ONLINE",
    required this.phiVanChuyen,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    "khachHangId": khachHangId,
    "kenhBan": kenhBan,
    "phiVanChuyen": phiVanChuyen,
    "items": items.map((i) => i.toJson()).toList(),
  };
}

class CheckoutItem {
  final int bienTheId;
  final int soLuong;
  final double donGia;

  CheckoutItem({required this.bienTheId, required this.soLuong, required this.donGia});

  Map<String, dynamic> toJson() => {
    "bienTheId": bienTheId,
    "soLuong": soLuong,
    "donGia": donGia,
  };
}