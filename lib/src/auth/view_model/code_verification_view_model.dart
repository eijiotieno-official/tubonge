import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/models/phone_model.dart';
import '../model/base/auth_state_model.dart';
import '../model/provider/auth_state_provider.dart';
import '../model/provider/firebase_auth_service_provider.dart';
import '../model/service/firebase_auth_service.dart';

// ViewModel for handling code verification process.
class CodeVerificationViewModel extends StateNotifier<AsyncValue> {
  final FirebaseAuthService _firebaseAuthService; // Firebase authentication service
  final Ref _ref; // Riverpod reference to access providers
  final Logger _logger = Logger(); // Logger for logging actions

  // Constructor
  CodeVerificationViewModel(this._firebaseAuthService, this._ref)
      : super(const AsyncValue.data(null)); // Initial state is null

  // The main method for handling the code verification process
  Future<void> call() async {
    _logger.i("Starting code verification...");
    state = const AsyncValue.loading(); // Set state to loading

    final AuthState authState = _ref.watch(authStateProvider); // Get current authentication state

    final String? verificationId = authState.verificationId; // Get verificationId from state
    final String? smsCode = authState.optCode; // Get the SMS code from state

    _logger.i("Using verificationId: $verificationId, smsCode: $smsCode");

    final PhoneModel? phone = authState.phone; // Get phone details from state

    // Verify the code with FirebaseAuthService
    final Either<String, User?> result = await _firebaseAuthService.verifyCode(
      phone: phone ?? PhoneModel.empty(), // Pass phone model, or empty if null
      verificationId: verificationId,
      smsCode: smsCode,
    );

    if (!mounted) return; // Ensure that the widget is still mounted before updating state

    // Update state based on the result of code verification
    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current), // If error, set state to error
      (userCredential) {
        // If successful, set state to data with user credential
        return AsyncValue.data(userCredential);
      },
    );
  }
}

// Riverpod provider to expose the CodeVerificationViewModel
final codeVerificationViewModelProvider =
    StateNotifierProvider<CodeVerificationViewModel, AsyncValue>((ref) {
  final FirebaseAuthService firebaseAuthService =
      ref.watch(firebaseAuthServiceProvider); // Get instance of FirebaseAuthService from provider
  return CodeVerificationViewModel(firebaseAuthService, ref);
});
