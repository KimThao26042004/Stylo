class AccountAddress {
  final int diaChiId;
  final String diaChiChiTiet;
  final String loaiDiaChi;
  final bool isDefault;

  AccountAddress({
    required this.diaChiId,
    required this.diaChiChiTiet,
    required this.loaiDiaChi,
    required this.isDefault,
  });

  factory AccountAddress.fromJson(Map<String, dynamic> json) {
    return AccountAddress(
      diaChiId: json['diaChiId'] ?? 0,
      diaChiChiTiet: json['diaChiChiTiet'] ?? '',
      loaiDiaChi: json['loaiDiaChi'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "diaChiID": diaChiId,
    "diaChiChiTiet": diaChiChiTiet,
    "loaiDiaChi": loaiDiaChi,
    "isDefault": isDefault,
  };
}
