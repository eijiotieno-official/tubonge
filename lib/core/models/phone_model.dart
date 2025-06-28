import 'dart:convert';

class PhoneModel {
  final String isoCode;
  final String dialCode;
  final String phoneNumber;
  PhoneModel({
    required this.isoCode,
    required this.dialCode,
    required this.phoneNumber,
  });

  static PhoneModel empty() {
    return PhoneModel(isoCode: "", dialCode: "", phoneNumber: "");
  }

  PhoneModel copyWith({
    String? isoCode,
    String? dialCode,
    String? phoneNumber,
  }) {
    return PhoneModel(
      isoCode: isoCode ?? this.isoCode,
      dialCode: dialCode ?? this.dialCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isoCode': isoCode,
      'dialCode': dialCode,
      'phoneNumber': phoneNumber,
    };
  }

  factory PhoneModel.fromMap(Map<String, dynamic> map) {
    return PhoneModel(
      isoCode: map['isoCode'] ?? '',
      dialCode: map['dialCode'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PhoneModel.fromJson(String source) =>
      PhoneModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'PhoneModel(isoCode: $isoCode, dialCode: $dialCode, phoneNumber: $phoneNumber)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PhoneModel &&
        other.isoCode == isoCode &&
        other.dialCode == dialCode &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode =>
      isoCode.hashCode ^ dialCode.hashCode ^ phoneNumber.hashCode;

  bool get isValidPhoneNumber => phoneNumber.replaceAll(dialCode, "").isNotEmpty;
}
