class PriceResponse {
  final int price;

  PriceResponse({required this.price});

  factory PriceResponse.fromJson(Map<String, dynamic> json) {
    return PriceResponse(price: json['price'] ?? 0);
  }
}
