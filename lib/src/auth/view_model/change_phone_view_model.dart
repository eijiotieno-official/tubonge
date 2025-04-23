import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/models/phone_model.dart';
import '../model/base/auth_state_model.dart';
import '../model/provider/auth_state_provider.dart';
import '../model/provider/firebase_auth_service_provider.dart';
import '../model/service/firebase_auth_service.dart';

/// A StateNotifier that handles the process of changing the user's phone number
class ChangePhoneNumberNotifier extends StateNotifier<AsyncValue<bool>> {
  final FirebaseAuthService _firebaseAuthService; // Service for Firebase auth
  final Ref _ref; // Riverpod reference to access other providers

  // Constructor initializes the notifier with initial state as `false` (not changed yet)
  ChangePhoneNumberNotifier(this._firebaseAuthService, this._ref)
      : super(const AsyncValue.data(false));

  final Logger _logger = Logger(); // Logger for debugging/logging

  /// Main method to trigger the phone number change process
  Future<void> call() async {
    _logger.i("Change phone number process started.");
    state = const AsyncValue.loading(); // Set state to loading while processing

    // Get current authentication state
    final AuthState authState = _ref.watch(authStateProvider);

    // Extract phone number, verification ID, and SMS code from auth state
    final PhoneModel? phone = authState.phone;
    final String? verificationId = authState.verificationId;
    final String? smsCode = authState.optCode;

    _logger.i(
        "Change phone number - phone: $phone, verificationId: $verificationId, smsCode: $smsCode");

    // Attempt to change the phone number using the provided credentials
    final Either<String, bool> result =
        await _firebaseAuthService.changePhoneNumber(
      newPhone: phone,
      verificationId: verificationId,
      smsCode: smsCode,
    );

    // Update the state based on the result (either error or success)
    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current), // On failure
      (success) => AsyncValue.data(success), // On success
    );
  }
}

/// Riverpod provider that exposes ChangePhoneNumberNotifier to the app
final changePhoneNumberProvider =
    StateNotifierProvider<ChangePhoneNumberNotifier, AsyncValue<bool>>(
  (ref) {
    // Watch and retrieve FirebaseAuthService from provider
    final FirebaseAuthService firebaseAuthService =
        ref.watch(firebaseAuthServiceProvider);

    // Return a new instance of the notifier with dependencies
    return ChangePhoneNumberNotifier(firebaseAuthService, ref);
  },
);
