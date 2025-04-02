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

class PhoneVerificationNotifier extends StateNotifier<AsyncValue<bool>> {
  PhoneVerificationNotifier({
    required this.ref,
    required this.authService,
  }) : super(const AsyncValue.data(false));

  final Ref ref;
  final AuthService authService;

  Future<void> call() async {
    try {
      _logger.i("Phone verification process started.");
      state = const AsyncValue.loading();

      final PhoneModel? phone = ref.read(phoneNumberProvider);

      _logger.i("Phone number read: $phone");

      await authService.verifyPhoneNumber(
        phone: phone,
        verificationFailed: (e) {
          _logger.e("Verification failed: ${e.message}");
          state = AsyncValue.error(
              "Verification failed: ${e.message}", StackTrace.current);
        },
        codeSent: (String verificationId, int? resendToken) {
          _logger.i(
              "Code sent. verificationId: $verificationId, resendToken: $resendToken");
          ref.read(verificationIdProvider.notifier).state = verificationId;
          ref.read(resendTokenProvider.notifier).state = resendToken;
          ref.read(timerProvider.notifier).startTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _logger.i(
              "Code auto retrieval timeout. verificationId: $verificationId");
          ref.read(verificationIdProvider.notifier).state = verificationId;
        },
      );
    } catch (e) {
      _logger.e("Exception in phone verification process: $e");
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final phoneVerificationProvider = StateNotifierProvider.autoDispose<
    PhoneVerificationNotifier, AsyncValue<bool>>((ref) {
  final AuthService authService = ref.read(authServiceProvider);
  return PhoneVerificationNotifier(
    ref: ref,
    authService: authService,
  );
});
