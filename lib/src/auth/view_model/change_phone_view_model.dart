import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/phone_model.dart';
import '../model/base/auth_state_model.dart';
import '../model/provider/auth_state_provider.dart';
import '../model/service/firebase_auth_service.dart';

class ChangePhoneNumberNotifier extends StateNotifier<AsyncValue<bool>> {
  final Ref _ref;

  ChangePhoneNumberNotifier(this._ref) : super(const AsyncValue.data(false));

  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  Future<void> call() async {
    state = const AsyncValue.loading();

    final AuthState authState = _ref.watch(authStateProvider);

    final PhoneModel? phone = authState.phone;
    final String? verificationId = authState.verificationId;
    final String? smsCode = authState.optCode;

    final Either<String, bool> result =
        await _firebaseAuthService.changePhoneNumber(
      newPhone: phone,
      verificationId: verificationId,
      smsCode: smsCode,
    );

    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current),
      (success) => AsyncValue.data(success),
    );
  }
}

final changePhoneNumberProvider = StateNotifierProvider.autoDispose<
    ChangePhoneNumberNotifier, AsyncValue<bool>>(
  (ref) {
    return ChangePhoneNumberNotifier(ref);
  },
);
