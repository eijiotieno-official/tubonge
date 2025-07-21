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

  bool get isValidPhoneNumber =>
      phoneNumber.replaceAll(dialCode, "").isNotEmpty;

  /// Formats a phone number string for display in a readable format
  static String formatPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return "your phone number";
    }

    // Remove any non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Format based on length
    if (digitsOnly.length == 10) {
      // Format as (XXX) XXX-XXXX
      return "(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}";
    } else if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
      // Format as +1 (XXX) XXX-XXXX
      return "+1 (${digitsOnly.substring(1, 4)}) ${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7)}";
    } else if (digitsOnly.length > 10) {
      // For international numbers, show country code + last 10 digits
      final countryCode = digitsOnly.substring(0, digitsOnly.length - 10);
      final localNumber = digitsOnly.substring(digitsOnly.length - 10);
      return "+$countryCode (${localNumber.substring(0, 3)}) ${localNumber.substring(3, 6)}-${localNumber.substring(6)}";
    } else {
      // Fallback to original number
      return phoneNumber;
    }
  }
}
