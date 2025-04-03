import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/models/phone_model.dart';
import '../model/provider/auth_state_provider.dart';
import '../model/provider/firebase_auth_service_provider.dart';
import '../model/service/firebase_auth_service.dart';
import '../model/util/firebase_auth_error_util.dart';
import '../model/provider/timer_provider.dart';

class PhoneVerificationViewModel extends StateNotifier<AsyncValue> {
  final FirebaseAuthService _firebaseAuthService;
  final FirebaseAuthErrorUtil _firebaseAuthErrorUtil;
  final Ref _ref;
  PhoneVerificationViewModel(
      this._firebaseAuthService, this._firebaseAuthErrorUtil, this._ref)
      : super(AsyncValue.data(null));

  final Logger _logger = Logger();

  Future<void> call() async {
    try {
      PhoneModel? phone = _ref.watch(authStateProvider).phone;
      _logger.i("Starting phone verification...");

      state = AsyncValue.loading();
      _logger.i("State changed to loading.");

      if (phone == null) {
        _logger.e("Phone number is empty.");
        state = AsyncValue.error("Phone number is empty", StackTrace.current);
        return;
      }

      _logger.i("Phone number provided: ${phone.phoneNumber}");
      final Either<String, void> result =
          await _firebaseAuthService.verifyPhoneNumber(
        phone: phone,
        verificationFailed: _verificationFailed,
        codeSent: _codeSent,
        codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout,
      );

      if (!mounted) return;

      state = result.fold(
        (error) => AsyncValue.error(error, StackTrace.current),
        (_) => AsyncValue.data(null),
      );
    } catch (e) {
      final String message = _firebaseAuthErrorUtil.handleException(e);
      _logger.e("Exception in phone verification process: $message");
      state = AsyncValue.error(message, StackTrace.current);
    }
  }

  void _verificationFailed(FirebaseAuthException error) {
    final String message = _firebaseAuthErrorUtil.handleException(error);
    _logger.e("Verification failed: $message");
    state = AsyncValue.error(message, StackTrace.current);
  }

  void _codeSent(String verificationId, [int? forceResendingToken]) {
    _logger.i("Code sent. Verification ID: $verificationId");
    _logger.i("Resend token: ${forceResendingToken ?? 'None'}");

    _ref.read(authStateProvider.notifier).updateState(
          resendToken: forceResendingToken,
          verificationId: verificationId,
        );

    _logger.i("Auth state updated with verification ID and resend token.");

    _ref.read(timerProvider.notifier).startTimer();
    _logger.i("Timer started.");
  }

  void _codeAutoRetrievalTimeout(String verificationId) {
    _logger.i("Code auto retrieval timeout. Verification ID: $verificationId");

    _ref.read(authStateProvider.notifier).updateState(
          verificationId: verificationId,
        );
    _logger.i("Auth state updated with verification ID.");
  }
}

final phoneVerificationViewModelProvider =
    StateNotifierProvider<PhoneVerificationViewModel, AsyncValue>(
  (ref) {
    final FirebaseAuthService firebaseAuthService =
        ref.watch(firebaseAuthServiceProvider);
    final FirebaseAuthErrorUtil firebaseAuthErrorUtil = FirebaseAuthErrorUtil();
    return PhoneVerificationViewModel(
        firebaseAuthService, firebaseAuthErrorUtil, ref);
  },
);
