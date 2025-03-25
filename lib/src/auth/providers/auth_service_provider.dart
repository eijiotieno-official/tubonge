import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/phone_model.dart';
import '../services/auth_service.dart';
import 'timer_provider.dart';

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
      state = const AsyncValue.loading();

      final phone = ref.read(phoneNumberProvider);

      await authService.verifyPhoneNumber(
        phone: phone,
        verificationFailed: (e) {
          state = AsyncValue.error(
              "Verification failed: ${e.message}", StackTrace.current);
        },
        codeSent: (String verificationId, int? resendToken) {
          ref.read(verificationIdProvider.notifier).state = verificationId;
          ref.read(resendTokenProvider.notifier).state = resendToken;
          ref.read(timerProvider.notifier).startTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          ref.read(verificationIdProvider.notifier).state = verificationId;
        },
      );
    } catch (e) {
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
    state = const AsyncValue.loading();

    final verificationId = ref.read(verificationIdProvider);
    final smsCode = ref.read(otpCodeProvider);

    final result = await authService.verifyCode(
      verificationId: verificationId,
      smsCode: smsCode,
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
      state = const AsyncValue.loading();

      final phone = ref.read(phoneNumberProvider);
      final resendToken = ref.read(resendTokenProvider);

      await authService.resendCode(
        phone: phone,
        resendToken: resendToken,
        verificationFailed: (e) {
          state = AsyncValue.error(
              "Verification failed: ${e.message}", StackTrace.current);
        },
        codeSent: (String verificationId, int? newResendToken) {
          ref.read(verificationIdProvider.notifier).state = verificationId;
          ref.read(resendTokenProvider.notifier).state = newResendToken;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          ref.read(verificationIdProvider.notifier).state = verificationId;
        },
      );
    } catch (e) {
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
    state = const AsyncValue.loading();

    final phone = ref.read(phoneNumberProvider);
    final verificationId = ref.read(verificationIdProvider);
    final smsCode = ref.read(otpCodeProvider);

    final result = await authService.changePhoneNumber(
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
    state = const AsyncValue.loading();

    final result = await authService.deleteAccount();

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
    state = const AsyncValue.loading();

    final result = await authService.signOut();

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
