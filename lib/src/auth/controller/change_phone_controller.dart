
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/models/phone_model.dart';
import '../providers/auth_service_provider.dart';
import '../providers/otp_code_provider.dart';
import '../providers/phone_number_provider.dart';
import '../providers/verification_id_provider.dart';
import '../services/auth_service.dart';

final Logger _logger = Logger();

class ChangePhoneNumberNotifier extends StateNotifier<AsyncValue<bool>> {
  ChangePhoneNumberNotifier({
    required this.ref,
    required this.authService,
  }) : super(const AsyncValue.data(false));

  final Ref ref;
  final AuthService authService;

  Future<void> call() async {
    _logger.i("Change phone number process started.");
    state = const AsyncValue.loading();

    final PhoneModel? phone = ref.read(phoneNumberProvider);

    final String? verificationId = ref.read(verificationIdProvider);

    final String? smsCode = ref.read(otpCodeProvider);

    _logger.i(
        "Change phone number - phone: $phone, verificationId: $verificationId, smsCode: $smsCode");

    final Either<String, bool> result = await authService.changePhoneNumber(
      newPhone: phone,
      verificationId: verificationId,
      smsCode: smsCode,
    );

    result.fold(
      (error) => _logger.e("Change phone number failed: $error"),
      (success) => _logger.i("Phone number changed successfully."),
    );

    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current),
      (success) => AsyncValue.data(success),
    );
  }
}

final changePhoneNumberProvider =
    StateNotifierProvider<ChangePhoneNumberNotifier, AsyncValue<bool>>((ref) {
  final AuthService authService = ref.read(authServiceProvider);

  return ChangePhoneNumberNotifier(
    ref: ref,
    authService: authService,
  );
});
