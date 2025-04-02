import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/models/phone_model.dart';
import '../providers/auth_service_provider.dart';
import '../providers/otp_code_provider.dart';
import '../providers/phone_number_provider.dart';
import '../providers/verification_id_provider.dart';
import '../services/auth_service.dart';

final Logger _logger = Logger();

class CodeVerificationNotifier
    extends StateNotifier<AsyncValue<UserCredential?>> {
  CodeVerificationNotifier({
    required this.ref,
    required this.authService,
  }) : super(const AsyncValue.data(null));

  final Ref ref;
  final AuthService authService;

  Future<void> call() async {
    _logger.i("Code verification process started.");
    state = const AsyncValue.loading();

    final String? verificationId = ref.read(verificationIdProvider);

    final String? smsCode = ref.read(otpCodeProvider);

    _logger.i("Using verificationId: $verificationId, smsCode: $smsCode");

    final PhoneModel? phone = ref.read(phoneNumberProvider);

    final Either<String, UserCredential> result = await authService.verifyCode(
      phone: phone ?? PhoneModel.empty(),
      verificationId: verificationId,
      smsCode: smsCode,
    );

    if (!mounted) return;

    result.fold(
      (error) => _logger.e("Code verification failed: $error"),
      (userCredential) => _logger
          .i("Code verified successfully. UserCredential: $userCredential"),
    );

    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current),
      (userCredential) => AsyncValue.data(userCredential),
    );
  }
}

final codeVerificationProvider = StateNotifierProvider.autoDispose<
    CodeVerificationNotifier, AsyncValue<UserCredential?>>((ref) {
  final AuthService authService = ref.read(authServiceProvider);

  return CodeVerificationNotifier(
    ref: ref,
    authService: authService,
  );
});
