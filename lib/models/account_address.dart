class AccountAddress {
  final int diaChiID;
  final String diaChiChiTiet;
  final String loaiDiaChi;
  final bool isDefault;

  AccountAddress({
    required this.diaChiID,
    required this.diaChiChiTiet,
    required this.loaiDiaChi,
    required this.isDefault,
  });

  factory AccountAddress.fromJson(Map<String, dynamic> json) {
    return AccountAddress(
      diaChiID: json['diaChiID'] ?? 0,
      diaChiChiTiet: json['diaChiChiTiet'] ?? '',
      loaiDiaChi: json['loaiDiaChi'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "diaChiID": diaChiID,
    "diaChiChiTiet": diaChiChiTiet,
    "loaiDiaChi": loaiDiaChi,
    "isDefault": isDefault,
  };
}
