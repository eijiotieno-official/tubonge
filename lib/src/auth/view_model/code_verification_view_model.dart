import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/models/phone_model.dart';
import '../model/base/auth_state_model.dart';
import '../model/provider/auth_state_provider.dart';
import '../model/provider/firebase_auth_service_provider.dart';
import '../model/service/firebase_auth_service.dart';

class CodeVerificationViewModel extends StateNotifier<AsyncValue> {
  final FirebaseAuthService _firebaseAuthService;
  final Ref _ref;
  final Logger _logger = Logger();

  CodeVerificationViewModel(this._firebaseAuthService, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> call() async {
    _logger.i("Starting code verification...");
    state = const AsyncValue.loading();

    final AuthState authState = _ref.watch(authStateProvider);

    final String? verificationId = authState.verificationId;
    final String? smsCode = authState.optCode;

    _logger.i("Using verificationId: $verificationId, smsCode: $smsCode");

    final PhoneModel? phone = authState.phone;

    final Either<String, User?> result = await _firebaseAuthService.verifyCode(
      phone: phone ?? PhoneModel.empty(),
      verificationId: verificationId,
      smsCode: smsCode,
    );

    if (!mounted) return;

    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current),
      (userCredential) {
        return AsyncValue.data(userCredential);
      },
    );
  }
}

final codeVerificationViewModelProvider =
    StateNotifierProvider<CodeVerificationViewModel, AsyncValue>((ref) {
  final FirebaseAuthService firebaseAuthService =
      ref.watch(firebaseAuthServiceProvider);
  return CodeVerificationViewModel(firebaseAuthService, ref);
});
