import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/models/phone_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/user_service.dart';
import '../util/firebase_auth_error_util.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseAuthErrorUtil _firebaseAuthErrorUtil;
  final UserService _userService;

  FirebaseAuthService({
    required FirebaseAuth firebaseAuth,
    required FirebaseAuthErrorUtil firebaseAuthErrorUtil,
    required UserService userService,
  })  : _firebaseAuth = firebaseAuth,
        _firebaseAuthErrorUtil = firebaseAuthErrorUtil,
        _userService = userService;

  User? get _currentUser => _firebaseAuth.currentUser;

  Future<Either<String, void>> verifyPhoneNumber({
    required PhoneModel? phone,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      if (phone == null) {
        return Left("Phone number is required.");
      }

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone.phoneNumber,
        verificationCompleted: (phoneAuthCredential) async {
          final Either<String, User?> result = await signInWithCredential(
              phoneAuthCredential,
              phoneNumber: phone.phoneNumber);

          result.fold(
            (error) {
              return Left(error);
            },
            (user) async {
              UserModel model = UserModel.empty;

              if (user != null) {
                await _userService.authenticatedUserHandler(
                  model.copyWith(
                    id: user.uid,
                    phone: phone,
                  ),
                );
              }
            },
          );
        },
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: Duration(seconds: 60),
      );

      return Right(null);
    } catch (e) {
      final message = _firebaseAuthErrorUtil.handleException(e,
          phoneNumber: phone?.phoneNumber);
      return Left(message);
    }
  }

  Future<Either<String, User?>> verifyCode({
    required PhoneModel phone,
    required String? verificationId,
    required String? smsCode,
  }) async {
    if (verificationId == null || smsCode == null) {
      return Left("Missing verification ID or SMS code.");
    }

    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredentialResult = await signInWithCredential(credential,
          phoneNumber: phone.phoneNumber);

      return userCredentialResult.fold(
        (error) => Left(error),
        (user) async {
          UserModel model = UserModel.empty;

          if (user != null) {
            await _userService.authenticatedUserHandler(
              model.copyWith(
                id: user.uid,
                phone: phone,
              ),
            );
          }

          return Right(user);
        },
      );
    } catch (e) {
      final message = _firebaseAuthErrorUtil.handleException(e,
          phoneNumber: phone.phoneNumber);
      return Left(message);
    }
  }

  Future<Either<String, bool>> resendCode({
    required PhoneModel? phone,
    required int? resendToken,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      if (phone == null) {
        return Left("Phone number is required.");
      }

      if (resendToken == null) {
        return Left("Resend token is required.");
      }

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone.phoneNumber,
        forceResendingToken: resendToken,
        verificationCompleted: (phoneAuthCredential) async {
          final Either<String, User?> result = await signInWithCredential(
              phoneAuthCredential,
              phoneNumber: phone.phoneNumber);

          result.fold(
            (error) {
              return Left(error);
            },
            (user) async {
              UserModel model = UserModel.empty;

              if (user != null) {
                await _userService.authenticatedUserHandler(
                  model.copyWith(
                    id: user.uid,
                    phone: phone,
                  ),
                );
              }
            },
          );
        },
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );

      return Right(true);
    } catch (e) {
      final message = _firebaseAuthErrorUtil.handleException(e,
          phoneNumber: phone?.phoneNumber);
      return Left(message);
    }
  }

  Future<Either<String, bool>> changePhoneNumber({
    required PhoneModel? newPhone,
    required String? verificationId,
    required String? smsCode,
  }) async {
    try {
      if (newPhone == null) {
        return Left("Phone number is required.");
      }

      if (verificationId == null || smsCode == null || smsCode.isEmpty) {
        return Left("Missing verification ID or SMS code.");
      }

      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      if (_currentUser == null) return Left('No user signed in.');

      await _currentUser?.updatePhoneNumber(credential);

      return Right(true);
    } catch (e) {
      final message = _firebaseAuthErrorUtil.handleException(e,
          phoneNumber: newPhone?.phoneNumber);
      return Left(message);
    }
  }

  Future<Either<String, bool>> deleteAccount() async {
    try {
      if (_currentUser == null) return Left('No user signed in.');

      await _currentUser?.delete();

      return Right(true);
    } catch (e) {
      final message = _firebaseAuthErrorUtil.handleException(e);
      return Left(message);
    }
  }

  Future<Either<String, bool>> signOut() async {
    try {
      await _firebaseAuth.signOut();

      return Right(true);
    } catch (e) {
      final message = _firebaseAuthErrorUtil.handleException(e);
      return Left(message);
    }
  }

  Future<Either<String, User?>> signInWithCredential(
      PhoneAuthCredential phoneAuthCredential,
      {String? phoneNumber}) async {
    try {
      final UserCredential credential =
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);

      return Right(credential.user);
    } catch (e) {
      final message =
          _firebaseAuthErrorUtil.handleException(e, phoneNumber: phoneNumber);
      return Left(message);
    }
  }
}
