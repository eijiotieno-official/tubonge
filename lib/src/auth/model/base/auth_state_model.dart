
import '../../../../core/models/phone_model.dart';

class AuthState {
  final PhoneModel? phone;
  final String? optCode;
  final int? resendToken;
  final String? verificationId;

  AuthState({
    this.phone,
    this.optCode,
    this.resendToken,
    this.verificationId,
  });

  static AuthState get empty => AuthState();

  AuthState copyWith({
    PhoneModel? phone,
    String? optCode,
    int? resendToken,
    String? verificationId,
  }) {
    return AuthState(
      phone: phone ?? this.phone,
      optCode: optCode ?? this.optCode,
      resendToken: resendToken ?? this.resendToken,
      verificationId: verificationId ?? this.verificationId,
    );
  }
}
