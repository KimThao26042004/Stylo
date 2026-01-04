class AccountProfile {
  final String? fullName;
  final String? email;        // CHỈ ĐỌC – KHÔNG UPDATE
  final String? phone;
  final String? gender;
  final String? dateOfBirth;  // yyyy-MM-dd

  AccountProfile({
    this.fullName,
    this.email,
    this.phone,
    this.gender,
    this.dateOfBirth,
  });

  /// ================== FROM API ==================
  factory AccountProfile.fromJson(Map<String, dynamic> json) {
    return AccountProfile(
      fullName: json['fullName'] as String?,
      email: json['email'] as String?, // backend trả về → chỉ hiển thị
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : json['dateOfBirth'].toString().substring(0, 10),
    );
  }

  /// ================== TO API (UPDATE) ==================
  /// ⚠️ KHÔNG GỬI EMAIL
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'gender': gender,
      'dateOfBirth': dateOfBirth, // yyyy-MM-dd
    };
  }
}