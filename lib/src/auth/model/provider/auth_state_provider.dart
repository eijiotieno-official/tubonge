import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubonge/core/models/phone_model.dart';
import '../base/auth_state_model.dart';

class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(AuthState.empty);

  void updateState({
    PhoneModel? phone,
    String? optCode,
    int? resendToken,
    String? verificationId,
  }) {
    state = state.copyWith(
      phone: phone,
      optCode: optCode,
      resendToken: resendToken,
      verificationId: verificationId,
    );
  }
}

final authStateProvider =
    StateNotifierProvider.autoDispose<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier();
});
