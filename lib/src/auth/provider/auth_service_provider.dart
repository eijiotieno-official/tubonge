import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/phone_model.dart';
import '../service/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final phoneNumberProvider =
    StateProvider.autoDispose<PhoneModel?>((ref) => null);

final verificationIdProvider =
    StateProvider.autoDispose<String?>((ref) => null);

final resendTokenProvider = StateProvider.autoDispose<int?>((ref) => null);

final verifyPhoneNumberProvider = FutureProvider.autoDispose<bool>((ref) async {
  final authService = ref.read(authServiceProvider);
  final phone = ref.watch(phoneNumberProvider);

  final result = await authService.verifyPhoneNumber(
    phone: phone,
    verificationFailed: (e) {
      throw Exception("Verification failed: ${e.message}");
    },
    codeSent: (String verificationId, int? resendToken) {
      ref.read(verificationIdProvider.notifier).state = verificationId;
      ref.read(resendTokenProvider.notifier).state = resendToken;
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      ref.read(verificationIdProvider.notifier).state = verificationId;
    },
  );

  return result.fold(
    (error) => throw Exception(error),
    (success) => success,
  );
});

final otpCodeProvider = StateProvider.autoDispose<String?>((ref) => null);

final verifyCodeProvider =
    FutureProvider.autoDispose<UserCredential>((ref) async {
  final authService = ref.read(authServiceProvider);

  final verificationId = ref.watch(verificationIdProvider);

  final smsCode = ref.watch(otpCodeProvider);

  final result = await authService.verifyCode(
    verificationId: verificationId,
    smsCode: smsCode,
  );

  return result.fold(
    (error) => throw Exception(error),
    (userCredential) => userCredential,
  );
});

final resendCodeProvider = FutureProvider.autoDispose<bool>((ref) async {
  final authService = ref.read(authServiceProvider);
  final phone = ref.watch(phoneNumberProvider);
  final resendToken = ref.watch(resendTokenProvider);

  final result = await authService.resendCode(
    phone: phone,
    resendToken: resendToken,
    verificationFailed: (e) {
      throw Exception("Verification failed: ${e.message}");
    },
    codeSent: (String verificationId, int? resendToken) {
      ref.read(verificationIdProvider.notifier).state = verificationId;
      ref.read(resendTokenProvider.notifier).state = resendToken;
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      ref.read(verificationIdProvider.notifier).state = verificationId;
    },
  );

  return result.fold(
    (error) => throw Exception(error),
    (success) => success,
  );
});

final changePhoneNumberProvider = FutureProvider<bool>(
  (ref) async {
    final authService = ref.read(authServiceProvider);

    final phone = ref.watch(phoneNumberProvider);

    if (phone == null || phone.phoneNumber.isEmpty) {
      throw Exception("Phone number is required.");
    }

    final verificationId = ref.watch(verificationIdProvider);

    final smsCode = ref.watch(otpCodeProvider);

    if (verificationId == null || smsCode == null || smsCode.isEmpty) {
      throw Exception("Missing verification ID or SMS code.");
    }

    final result = await authService.changePhoneNumber(
      newPhoneNumber: phone.phoneNumber,
      verificationId: verificationId,
      smsCode: smsCode,
    );

    return result.fold(
      (error) => throw Exception(error),
      (success) => success,
    );
  },
);

final deleteAccountProvider = FutureProvider<bool>((ref) async {
  final authService = ref.read(authServiceProvider);
  final result = await authService.deleteAccount();
  return result.fold(
    (error) => throw Exception(error),
    (success) => success,
  );
});

final signOutProvider = FutureProvider<bool>((ref) async {
  final authService = ref.read(authServiceProvider);
  final result = await authService.signOut();
  return result.fold(
    (error) => throw Exception(error),
    (success) => success,
  );
});

final currentUserProvider = Provider<User?>((ref) {
  final authService = ref.read(authServiceProvider);
  final result = authService.getCurrentUser();
  return result.fold(
    (error) => throw Exception(error),
    (user) => user,
  );
});
