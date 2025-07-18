import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/phone_model.dart';
import '../model/base/auth_state_model.dart';
import '../model/provider/auth_state_provider.dart';
import '../model/service/firebase_auth_service.dart';

class CodeVerificationViewModel extends StateNotifier<AsyncValue> {
  final Ref _ref;

  CodeVerificationViewModel(this._ref) : super(const AsyncValue.data(null));

  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  Future<void> call() async {
    state = const AsyncValue.loading();

    final AuthState authState = _ref.watch(authStateProvider);

    final String? verificationId = authState.verificationId;

    final PhoneModel? phone = authState.phone;

    final String? smsCode = authState.optCode;

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
    StateNotifierProvider.autoDispose<CodeVerificationViewModel, AsyncValue>(
        (ref) {
  return CodeVerificationViewModel(ref);
});
