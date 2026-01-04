class LocationModel {
  final String name;
  final int code;

  LocationModel({required this.name, required this.code});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] ?? '',
      code: json['code'] ?? 0,
    );
  }

  // Để so sánh các Object trong DropdownButton
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LocationModel && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}