import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/models/phone_model.dart';
import '../model/provider/auth_state_provider.dart';
import '../model/provider/firebase_auth_service_provider.dart';
import '../model/provider/timer_provider.dart';
import '../model/service/firebase_auth_service.dart';
import '../model/util/firebase_auth_error_util.dart';

// ViewModel for handling the phone verification process.
class PhoneVerificationViewModel extends StateNotifier<AsyncValue> {
  final FirebaseAuthService
      _firebaseAuthService; // Service for Firebase authentication.
  final FirebaseAuthErrorUtil
      _firebaseAuthErrorUtil; // Utility for handling Firebase authentication errors.
  final Ref _ref; // Riverpod reference for accessing other providers.

  // Constructor to initialize the service, error handler, and Riverpod reference.
  PhoneVerificationViewModel(
      this._firebaseAuthService, this._firebaseAuthErrorUtil, this._ref)
      : super(AsyncValue.data(null)); // Set initial state to null.

  final Logger _logger = Logger(); // Logger for logging events.

  // Main method for initiating the phone verification process.
  Future<void> call() async {
    try {
      // Retrieve the phone model from the auth state provider.
      PhoneModel? phone = _ref.watch(authStateProvider).phone;
      _logger.i("Starting phone verification...");

      // Set the state to loading to indicate progress.
      state = AsyncValue.loading();
      _logger.i("State changed to loading.");

      // Check if phone number is provided.
      if (phone == null) {
        _logger.e("Phone number is empty.");
        // If no phone number, set the state to error.
        state = AsyncValue.error("Phone number is empty", StackTrace.current);
        return;
      }

      _logger.i("Phone number provided: ${phone.phoneNumber}");

      // Call Firebase service to initiate phone number verification.
      final Either<String, void> result =
          await _firebaseAuthService.verifyPhoneNumber(
        phone: phone, // Pass the phone number model.
        verificationFailed:
            _verificationFailed, // Callback for verification failure.
        codeSent: _codeSent, // Callback for when the verification code is sent.
        codeAutoRetrievalTimeout:
            _codeAutoRetrievalTimeout, // Timeout callback.
      );

      // Check if the widget is still mounted before updating state.
      if (!mounted) return;

      // Update state based on the result from the Firebase service.
      state = result.fold(
        (error) => AsyncValue.error(
            error, StackTrace.current), // On error, set state to error.
        (_) => AsyncValue.data(null), // On success, set state to data.
      );
    } catch (e) {
      // Handle exceptions during the verification process.
      final String message = _firebaseAuthErrorUtil.handleException(e);
      _logger.e("Exception in phone verification process: $message");
      state = AsyncValue.error(message, StackTrace.current); // Set error state.
    }
  }

  // Callback for when verification fails.
  void _verificationFailed(FirebaseAuthException error) {
    final String message = _firebaseAuthErrorUtil.handleException(error);
    _logger.e("Verification failed: $message");
    state = AsyncValue.error(message, StackTrace.current); // Set error state.
  }

  // Callback for when the verification code is sent.
  void _codeSent(String verificationId, [int? forceResendingToken]) {
    _logger.i("Code sent. Verification ID: $verificationId");
    _logger.i("Resend token: ${forceResendingToken ?? 'None'}");

    // Update the authentication state with the verification ID and resend token.
    _ref.read(authStateProvider.notifier).updateState(
          resendToken: forceResendingToken,
          verificationId: verificationId,
        );

    _logger.i("Auth state updated with verification ID and resend token.");

    // Start the timer for OTP verification.
    _ref.read(timerProvider.notifier).startTimer();
    _logger.i("Timer started.");
  }

  // Callback for when auto-retrieval of the verification code times out.
  void _codeAutoRetrievalTimeout(String verificationId) {
    _logger.i("Code auto retrieval timeout. Verification ID: $verificationId");

    // Update the authentication state with the verification ID.
    _ref.read(authStateProvider.notifier).updateState(
          verificationId: verificationId,
        );
    _logger.i("Auth state updated with verification ID.");
  }
}

// Riverpod provider that exposes the PhoneVerificationViewModel.
final phoneVerificationViewModelProvider =
    StateNotifierProvider<PhoneVerificationViewModel, AsyncValue>(
  (ref) {
    // Get instances of FirebaseAuthService and FirebaseAuthErrorUtil from providers.
    final FirebaseAuthService firebaseAuthService =
        ref.watch(firebaseAuthServiceProvider);
    final FirebaseAuthErrorUtil firebaseAuthErrorUtil = FirebaseAuthErrorUtil();
    // Return an instance of PhoneVerificationViewModel.
    return PhoneVerificationViewModel(
        firebaseAuthService, firebaseAuthErrorUtil, ref);
  },
);
