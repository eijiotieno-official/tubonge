import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/phone_model.dart';
import '../model/provider/auth_state_provider.dart';
import '../model/provider/timer_provider.dart';
import '../model/service/firebase_auth_service.dart';
import '../model/util/firebase_auth_error_util.dart';

class PhoneVerificationViewModel extends StateNotifier<AsyncValue> {
  final Ref _ref;

  PhoneVerificationViewModel(this._ref) : super(const AsyncValue.data(null));

  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  Future<void> call() async {
    state = AsyncValue.loading();

    final PhoneModel? phone = _ref.watch(authStateProvider).phone;

    if (phone == null) {
      state = AsyncValue.error("Phone number is required", StackTrace.current);
      return;
    }

    await _firebaseAuthService.verifyPhoneNumber(
      phone: phone,
      verificationCompleted: (phoneAuthCredential) =>
          _verificationCompleted(phoneAuthCredential),
      verificationFailed: (error) =>
          _verificationFailed(error, phone.phoneNumber),
      codeSent: _codeSent,
      codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout,
    );
  }

  void _verificationCompleted(PhoneAuthCredential phoneAuthCredential) {
    state = AsyncValue.data(phoneAuthCredential);
  }

  void _verificationFailed(FirebaseAuthException error, String? phoneNumber) {
    final String message =
        FirebaseAuthErrorUtil.handleException(error, phoneNumber: phoneNumber);
    state = AsyncValue.error(message, StackTrace.current);
  }

  void _codeSent(String verificationId, [int? forceResendingToken]) {
    _ref.read(timerProvider.notifier).startTimer();

    _ref.read(authStateProvider.notifier).updateState(
          resendToken: forceResendingToken,
          verificationId: verificationId,
        );

    state = const AsyncValue.data(null);
  }

  void _codeAutoRetrievalTimeout(String verificationId) {
    _ref.read(authStateProvider.notifier).updateState(
          verificationId: verificationId,
        );

    state = AsyncValue.error("Code auto retrieval timeout", StackTrace.current);
  }
}

final phoneVerificationViewModelProvider =
    StateNotifierProvider<PhoneVerificationViewModel, AsyncValue>(
  (ref) {
    return PhoneVerificationViewModel(ref);
  },
);
