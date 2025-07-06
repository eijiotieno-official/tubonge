import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/phone_model.dart';
import '../model/base/auth_state_model.dart';
import '../model/provider/auth_state_provider.dart';
import '../model/provider/firebase_auth_service_provider.dart';
import '../model/provider/timer_provider.dart';
import '../model/service/firebase_auth_service.dart';
import '../model/util/firebase_auth_error_util.dart';

class ResendCodeViewModel extends StateNotifier<AsyncValue> {
  final FirebaseAuthService _firebaseAuthService;
  final FirebaseAuthErrorUtil _firebaseAuthErrorUtil;
  final Ref _ref;

  ResendCodeViewModel(
    this._firebaseAuthService,
    this._firebaseAuthErrorUtil,
    this._ref,
  ) : super(const AsyncValue.data(null));

  Future<void> call() async {
    try {
      state = const AsyncValue.loading();

      final AuthState authState = _ref.watch(authStateProvider);

      final PhoneModel? phone = authState.phone;
      final int? resendToken = authState.resendToken;

      final result = await _firebaseAuthService.resendCode(
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
    } catch (e) {
      final String message = _firebaseAuthErrorUtil.handleException(e);
      state = AsyncValue.error(message, StackTrace.current);
    }
  }

  void _verificationFailed(FirebaseAuthException error) {
    final String message = _firebaseAuthErrorUtil.handleException(error);
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
    final FirebaseAuthService firebaseAuthService =
        ref.watch(firebaseAuthServiceProvider);

    final FirebaseAuthErrorUtil firebaseAuthErrorUtil = FirebaseAuthErrorUtil();

    return ResendCodeViewModel(firebaseAuthService, firebaseAuthErrorUtil, ref);
  },
);
