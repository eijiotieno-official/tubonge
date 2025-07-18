import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/phone_model.dart';
import '../model/base/auth_state_model.dart';
import '../model/provider/auth_state_provider.dart';
import '../model/provider/timer_provider.dart';
import '../model/service/firebase_auth_service.dart';
import '../model/util/firebase_auth_error_util.dart';

class ResendCodeViewModel extends StateNotifier<AsyncValue> {
  final Ref _ref;

  ResendCodeViewModel(
    this._ref,
  ) : super(const AsyncValue.data(null));

  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  Future<void> call() async {
    state = const AsyncValue.loading();

    final AuthState authState = _ref.watch(authStateProvider);

    final PhoneModel? phone = authState.phone;
    final int? resendToken = authState.resendToken;

    final Either<String, bool> result = await _firebaseAuthService.resendCode(
      phone: phone,
      resendToken: resendToken,
      verificationFailed: _verificationFailed,
      codeSent: _codeSent,
      codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout,
    );

    if (!mounted) return;

    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current),
      (_) {
        return AsyncValue.data(null);
      },
    );
  }

  void _verificationFailed(FirebaseAuthException error) {
    final String message = FirebaseAuthErrorUtil.handleException(error);
    state = AsyncValue.error(message, StackTrace.current);
  }

  void _codeSent(String verificationId, [int? forceResendingToken]) {
    _ref.read(timerProvider.notifier).startTimer();
    _ref.read(authStateProvider.notifier).updateState(
          resendToken: forceResendingToken,
          verificationId: verificationId,
        );
  }

  void _codeAutoRetrievalTimeout(String verificationId) {
    _ref.read(authStateProvider.notifier).updateState(
          verificationId: verificationId,
        );
  }
}

final resendCodeViewModelProvider =
    StateNotifierProvider<ResendCodeViewModel, AsyncValue>(
  (ref) {
    return ResendCodeViewModel(ref);
  },
);
