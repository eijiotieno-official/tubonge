import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart'; // Import the logger package

import '../../../core/models/phone_model.dart';
import '../services/auth_service.dart';
import 'timer_provider.dart';

final _logger = Logger(); // Global logger instance

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final phoneNumberProvider =
    StateProvider.autoDispose<PhoneModel?>((ref) => null);

final verificationIdProvider =
    StateProvider.autoDispose<String?>((ref) => null);

final resendTokenProvider = StateProvider.autoDispose<int?>((ref) => null);

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

      final phone = ref.read(phoneNumberProvider);
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
  final authService = ref.read(authServiceProvider);
  return PhoneVerificationNotifier(
    ref: ref,
    authService: authService,
  );
});

final otpCodeProvider = StateProvider.autoDispose<String?>((ref) => null);

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

    final verificationId = ref.read(verificationIdProvider);
    final smsCode = ref.read(otpCodeProvider);
    _logger.i("Using verificationId: $verificationId, smsCode: $smsCode");

    final phone = ref.read(phoneNumberProvider);

    final result = await authService.verifyCode(
      phone: phone ?? PhoneModel.empty(),
      verificationId: verificationId,
      smsCode: smsCode,
    );

    // Check if the notifier is still mounted before updating state.
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
  final authService = ref.read(authServiceProvider);
  return CodeVerificationNotifier(
    ref: ref,
    authService: authService,
  );
});

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

      final phone = ref.read(phoneNumberProvider);
      final resendToken = ref.read(resendTokenProvider);
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
  final authService = ref.read(authServiceProvider);
  return ResendCodeNotifier(
    ref: ref,
    authService: authService,
  );
});

// ChangePhoneNumber StateNotifier
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

    final phone = ref.read(phoneNumberProvider);
    final verificationId = ref.read(verificationIdProvider);
    final smsCode = ref.read(otpCodeProvider);
    _logger.i(
        "Change phone number - phone: $phone, verificationId: $verificationId, smsCode: $smsCode");

    final result = await authService.changePhoneNumber(
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
  final authService = ref.read(authServiceProvider);
  return ChangePhoneNumberNotifier(
    ref: ref,
    authService: authService,
  );
});

// DeleteAccount StateNotifier
class DeleteAccountNotifier extends StateNotifier<AsyncValue<bool>> {
  DeleteAccountNotifier({
    required this.authService,
  }) : super(const AsyncValue.data(false));

  final AuthService authService;

  Future<void> call() async {
    _logger.i("Delete account process started.");
    state = const AsyncValue.loading();

    final result = await authService.deleteAccount();

    result.fold(
      (error) => _logger.e("Delete account failed: $error"),
      (success) => _logger.i("Account deleted successfully."),
    );

    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current),
      (success) => AsyncValue.data(success),
    );
  }
}

final deleteAccountProvider =
    StateNotifierProvider<DeleteAccountNotifier, AsyncValue<bool>>((ref) {
  final authService = ref.read(authServiceProvider);
  return DeleteAccountNotifier(
    authService: authService,
  );
});

// SignOut StateNotifier
class SignOutNotifier extends StateNotifier<AsyncValue<bool>> {
  SignOutNotifier({
    required this.authService,
  }) : super(const AsyncValue.data(false));

  final AuthService authService;

  Future<void> call() async {
    _logger.i("Sign out process started.");
    state = const AsyncValue.loading();

    final result = await authService.signOut();

    result.fold(
      (error) => _logger.e("Sign out failed: $error"),
      (success) => _logger.i("Signed out successfully."),
    );

    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current),
      (success) => AsyncValue.data(success),
    );
  }
}

final signOutProvider =
    StateNotifierProvider<SignOutNotifier, AsyncValue<bool>>((ref) {
  final authService = ref.read(authServiceProvider);
  return SignOutNotifier(
    authService: authService,
  );
});
