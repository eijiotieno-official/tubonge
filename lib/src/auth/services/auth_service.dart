import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/user_service.dart';
import '../../../core/models/phone_model.dart';
import 'auth_error_service.dart';

class AuthService {
  final FirebaseAuth _auth;
  final UserService _userService;
  final AuthErrorService _authErrorService;

  AuthService({
    required FirebaseAuth auth,
    required UserService userService,
    required AuthErrorService authErrorService,
  })  : _auth = auth,
        _userService = userService,
        _authErrorService = authErrorService;

  Future<Either<String, bool>> verifyPhoneNumber({
    required PhoneModel? phone,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      if (phone == null) {
        return Left("Phone number is required.");
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: phone.phoneNumber,
        verificationCompleted: (credential) async {
          final result = await signInWithCredential(credential);

          result.fold(
            (error) => throw FirebaseAuthException(
              code: 'verification_failed',
              message: error,
            ),
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
      final message = _authErrorService.handleException(exception: e);
      return Left(message);
    }
  }

  Future<Either<String, UserCredential>> verifyCode({
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
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;

      UserModel model = UserModel.empty;

      if (user != null) {
        await _userService.authenticatedUserHandler(
          model.copyWith(
            id: user.uid,
            phone: phone,
          ),
        );
      }

      return Right(userCredential);
    } catch (e) {
      final message = _authErrorService.handleException(exception: e);
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

      await _auth.verifyPhoneNumber(
        phoneNumber: phone.phoneNumber,
        forceResendingToken: resendToken,
        verificationCompleted: (credential) async {
          final result = await signInWithCredential(credential);

          result.fold(
            (error) => throw FirebaseAuthException(
              code: 'verification_failed',
              message: error,
            ),
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
      final message = _authErrorService.handleException(exception: e);
      return Left(message);
    }
  }

  Future<Either<String, User?>> signInWithCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    try {
      final UserCredential credential =
          await _auth.signInWithCredential(phoneAuthCredential);
      return Right(credential.user);
    } catch (e) {
      final message = _authErrorService.handleException(exception: e);
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
      final User? user = _auth.currentUser;
      if (user == null) return Left('No user signed in.');
      await user.updatePhoneNumber(credential);
      return Right(true);
    } catch (e) {
      final message = _authErrorService.handleException(exception: e);
      return Left(message);
    }
  }

  Future<Either<String, bool>> deleteAccount() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return Left('No user signed in.');
      await user.delete();
      return Right(true);
    } catch (e) {
      final message = _authErrorService.handleException(exception: e);
      return Left(message);
    }
  }

  Future<Either<String, bool>> signOut() async {
    try {
      await _auth.signOut();
      return Right(true);
    } catch (e) {
      final message = _authErrorService.handleException(exception: e);
      return Left(message);
    }
  }
}
