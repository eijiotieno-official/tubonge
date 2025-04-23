import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubonge/core/models/phone_model.dart'; // Import the PhoneModel
import '../base/auth_state_model.dart'; // Import the AuthState model

// A StateNotifier that manages the authentication state.
class AuthStateNotifier extends StateNotifier<AuthState> {
  // Initialize the state with an empty AuthState.
  AuthStateNotifier() : super(AuthState.empty);

  // Updates the authentication state with the given parameters.
  void updateState({
    PhoneModel? phone, // The phone model of the user (optional).
    String? optCode, // The OTP code received (optional).
    int? resendToken, // Token for re-sending the verification code (optional).
    String? verificationId, // The verification ID (optional).
  }) {
    // Update the state by copying the existing state and overriding the provided fields.
    state = state.copyWith(
      phone: phone, // Update the phone field in the state.
      optCode: optCode, // Update the OTP code in the state.
      resendToken: resendToken, // Update the resend token in the state.
      verificationId:
          verificationId, // Update the verification ID in the state.
    );
  }
}

// A Riverpod provider that exposes the AuthStateNotifier and the current AuthState.
final authStateProvider =
    StateNotifierProvider.autoDispose<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(); // Return an instance of AuthStateNotifier.
});
