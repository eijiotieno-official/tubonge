import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/models/phone_model.dart';
import '../providers/auth_service_provider.dart';
import '../providers/phone_number_provider.dart';
import '../providers/resend_toke_provider.dart';
import '../providers/timer_provider.dart';
import '../providers/verification_id_provider.dart';
import '../services/auth_service.dart';

final Logger _logger = Logger();

class ResendCodeNotifier extends StateNotifier<AsyncValue<bool>> {
  ResendCodeNotifier({
    required this.ref,
    required this.authService,
  }) : super(const AsyncValue.data(false));

  final Ref ref;
  final AuthService authService;

  Future<void> resendCode() async {
    try {
      _logger.i("Resend code process started.");
      state = const AsyncValue.loading();

      final PhoneModel? phone = ref.read(phoneNumberProvider);

      final int? resendToken = ref.read(resendTokenProvider);

      _logger.i("Resend code - phone: $phone, resendToken: $resendToken");

      await authService.resendCode(
        phone: phone,
        resendToken: resendToken,
        verificationFailed: (e) {
          _logger.e("Resend code verification failed: ${e.message}");
          state = AsyncValue.error(
              "Verification failed: ${e.message}", StackTrace.current);
        },
        codeSent: (String verificationId, int? newResendToken) {
          _logger.i(
              "Resend code sent. verificationId: $verificationId, newResendToken: $newResendToken");
          ref.read(verificationIdProvider.notifier).state = verificationId;
          ref.read(resendTokenProvider.notifier).state = newResendToken;
          ref.read(timerProvider.notifier).startTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _logger.i(
              "Resend code auto retrieval timeout. verificationId: $verificationId");
          ref.read(verificationIdProvider.notifier).state = verificationId;
        },
      );
    } catch (e) {
      _logger.e("Exception in resend code process: $e");
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final resendCodeProvider =
    StateNotifierProvider.autoDispose<ResendCodeNotifier, AsyncValue<bool>>(
        (ref) {
  final AuthService authService = ref.read(authServiceProvider);

  return ResendCodeNotifier(
    ref: ref,
    authService: authService,
  );
});
