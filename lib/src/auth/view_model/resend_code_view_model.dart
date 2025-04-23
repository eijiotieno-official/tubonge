import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/models/phone_model.dart';
import '../model/base/auth_state_model.dart';
import '../model/provider/auth_state_provider.dart';
import '../model/provider/firebase_auth_service_provider.dart';
import '../model/provider/timer_provider.dart';
import '../model/service/firebase_auth_service.dart';
import '../model/util/firebase_auth_error_util.dart';

/// ViewModel for resending OTP verification codes.
/// Manages async state and handles Firebase phone auth callbacks.
class ResendCodeViewModel extends StateNotifier<AsyncValue> {
  final FirebaseAuthService _firebaseAuthService; // Firebase Auth operations
  final FirebaseAuthErrorUtil
      _firebaseAuthErrorUtil; // Handles auth-related error formatting
  final Ref _ref; // Riverpod reference to access providers

  ResendCodeViewModel(
    this._firebaseAuthService,
    this._firebaseAuthErrorUtil,
    this._ref,
  ) : super(const AsyncValue.data(null)); // Initial state is "idle"

  final Logger _logger = Logger(); // Logger for debug/info/error logs

  /// Initiates the resend code process
  Future<void> call() async {
    try {
      _logger.i("Resend code process started.");
      state = const AsyncValue.loading(); // Set state to loading

      // Fetch current auth state
      final AuthState authState = _ref.watch(authStateProvider);

      final PhoneModel? phone = authState.phone; // Get stored phone number
      final int? resendToken =
          authState.resendToken; // Get last known resend token

      _logger.i("Resend code - phone: $phone, resendToken: $resendToken");

      // Attempt to resend the verification code
      final result = await _firebaseAuthService.resendCode(
        phone: phone,
        resendToken: resendToken,
        verificationFailed:
            _verificationFailed, // Callback if verification fails
        codeSent: _codeSent, // Callback when code is sent
        codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout, // Timeout callback
      );

      if (!mounted) return;

      // Update state depending on result
      state = result.fold(
        (error) => AsyncValue.error(error, StackTrace.current), // On failure
        (_) {
          return AsyncValue.data(null); // On success, return null data
        },
      );
    } catch (e) {
      // Handle general exceptions (not returned by the service)
      final String message = _firebaseAuthErrorUtil.handleException(e);
      _logger.e("Exception in resend code process: $message");
      state = AsyncValue.error(message, StackTrace.current);
    }
  }

  /// Callback for Firebase when verification fails
  void _verificationFailed(FirebaseAuthException error) {
    final String message = _firebaseAuthErrorUtil.handleException(error);
    _logger.e("Verification failed: $message");
    state = AsyncValue.error(message, StackTrace.current);
  }

  /// Callback when the verification code is successfully sent
  void _codeSent(String verificationId, [int? forceResendingToken]) {
    _logger.i("Code sent. Verification ID: $verificationId");
    _logger.i("Resend token: ${forceResendingToken ?? 'None'}");

    // Update auth state with new verification ID and token
    _ref.read(authStateProvider.notifier).updateState(
          resendToken: forceResendingToken,
          verificationId: verificationId,
        );

    _logger.i("Auth state updated with verification ID and resend token.");

    // Start countdown timer for resending
    _ref.read(timerProvider.notifier).startTimer();
    _logger.i("Timer started.");
  }

  /// Callback when auto-retrieval of the OTP code times out
  void _codeAutoRetrievalTimeout(String verificationId) {
    _logger.i("Code auto retrieval timeout. Verification ID: $verificationId");

    // Update only the verification ID in auth state
    _ref.read(authStateProvider.notifier).updateState(
          verificationId: verificationId,
        );

    _logger.i("Auth state updated with verification ID.");
  }
}

/// Riverpod provider for exposing ResendCodeViewModel to the app
final resendCodeViewModelProvider =
    StateNotifierProvider<ResendCodeViewModel, AsyncValue>(
  (ref) {
    final FirebaseAuthService firebaseAuthService =
        ref.watch(firebaseAuthServiceProvider);

    final FirebaseAuthErrorUtil firebaseAuthErrorUtil = FirebaseAuthErrorUtil();

    return ResendCodeViewModel(firebaseAuthService, firebaseAuthErrorUtil, ref);
  },
);
