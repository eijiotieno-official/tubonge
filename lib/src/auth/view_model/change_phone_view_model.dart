import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/models/phone_model.dart';
import '../model/base/auth_state_model.dart';
import '../model/provider/auth_state_provider.dart';
import '../model/provider/firebase_auth_service_provider.dart';
import '../model/service/firebase_auth_service.dart';

class ChangePhoneNumberNotifier extends StateNotifier<AsyncValue<bool>> {
  final FirebaseAuthService _firebaseAuthService;
  final Ref _ref;

  ChangePhoneNumberNotifier(this._firebaseAuthService, this._ref)
      : super(const AsyncValue.data(false));

  final Logger _logger = Logger();

  Future<void> call() async {
    _logger.i("Change phone number process started.");
    state = const AsyncValue.loading();

    final AuthState authState = _ref.watch(authStateProvider);

    final PhoneModel? phone = authState.phone;
    final String? verificationId = authState.verificationId;
    final String? smsCode = authState.optCode;

    _logger.i(
        "Change phone number - phone: $phone, verificationId: $verificationId, smsCode: $smsCode");

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

final changePhoneNumberProvider =
    StateNotifierProvider<ChangePhoneNumberNotifier, AsyncValue<bool>>(
  (ref) {
    final FirebaseAuthService firebaseAuthService =
        ref.watch(firebaseAuthServiceProvider);

    return ChangePhoneNumberNotifier(firebaseAuthService, ref);
  },
);
