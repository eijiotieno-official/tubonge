import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/models/phone_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/user_service.dart';
import '../util/firebase_auth_error_util.dart';

/// A service that manages Firebase Authentication operations.
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

  // Getter to retrieve the current signed-in user.
  User? get _currentUser => _firebaseAuth.currentUser;

  /// Verifies the phone number, sends OTP, and handles verification completion.
  Future<Either<String, void>> verifyPhoneNumber({
    required PhoneModel? phone, // The phone model containing the phone number
    required Function(FirebaseAuthException)
        verificationFailed, // Callback for verification failure
    required Function(String, int?) codeSent, // Callback when OTP code is sent
    required Function(String)
        codeAutoRetrievalTimeout, // Callback for auto retrieval timeout
  }) async {
    try {
      // Check if the phone number is provided; return error if null
      if (phone == null) {
        return Left("Phone number is required.");
      }

      // Initiate phone number verification via Firebase
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone.phoneNumber, // The phone number to verify
        verificationCompleted: (phoneAuthCredential) async {
          // This callback is triggered when verification is successfully completed
          final Either<String, User?> result =
              await signInWithCredential(phoneAuthCredential);

          result.fold(
            // If there's an error during sign-in, return the error message
            (error) {
              return Left(error);
            },
            // If user sign-in is successful, handle the authenticated user
            (user) async {
              UserModel model = UserModel.empty; // Create an empty user model

              if (user != null) {
                // Handle authenticated user (e.g., save user details in the system)
                await _userService.authenticatedUserHandler(
                  model.copyWith(
                    id: user.uid, // Set the user's ID
                    phone: phone, // Attach phone details to user model
                  ),
                );
              }
            },
          );
        },
        verificationFailed:
            verificationFailed, // Callback for verification failure
        codeSent: codeSent, // Callback for when the OTP code is sent
        codeAutoRetrievalTimeout:
            codeAutoRetrievalTimeout, // Callback for timeout
        timeout:
            Duration(seconds: 60), // Set timeout duration for OTP retrieval
      );

      return Right(
          null); // Return success if verification is initiated successfully
    } catch (e) {
      // If any error occurs, handle it and return the error message
      final message = _firebaseAuthErrorUtil.handleException(e);
      return Left(message);
    }
  }

  /// Verifies the SMS code received after phone number verification.
  Future<Either<String, User?>> verifyCode({
    required PhoneModel phone, // The phone model containing the phone details
    required String?
        verificationId, // The verification ID received during phone verification
    required String? smsCode, // The SMS code sent to the user
  }) async {
    // Check if verification ID or SMS code is missing and return an error if so
    if (verificationId == null || smsCode == null) {
      return Left("Missing verification ID or SMS code.");
    }

    try {
      // Create a PhoneAuthCredential using the verification ID and SMS code
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId:
            verificationId, // Verification ID received from Firebase
        smsCode: smsCode, // SMS code received by the user
      );

      // Sign in using the created credential
      final userCredentialResult = await signInWithCredential(credential);

      userCredentialResult.fold(
        // If there's an error during sign-in, return the error message
        (error) {
          return Left(error);
        },
        // If user sign-in is successful, handle the authenticated user
        (user) async {
          UserModel model = UserModel.empty; // Create an empty user model

          if (user != null) {
            // Handle authenticated user (e.g., save user details in the system)
            await _userService.authenticatedUserHandler(
              model.copyWith(
                id: user.uid, // Set the user's ID
                phone: phone, // Attach phone details to user model
              ),
            );
          }

          // Return the user object if authentication is successful
          return Right(user);
        },
      );

      return Right(
          null); // Return success if code verification and sign-in are successful
    } catch (e) {
      // If any error occurs, handle it and return the error message
      final message = _firebaseAuthErrorUtil.handleException(e);
      return Left(message);
    }
  }

  /// Resends the verification code to the phone number, handling re-sending token.
  Future<Either<String, bool>> resendCode({
    required PhoneModel? phone, // The phone model containing the phone details
    required int?
        resendToken, // The resend token received previously for re-verification
    required Function(FirebaseAuthException)
        verificationFailed, // Callback for verification failure
    required Function(String, int?)
        codeSent, // Callback when the OTP code is sent
    required Function(String)
        codeAutoRetrievalTimeout, // Callback for auto-retrieval timeout
  }) async {
    try {
      // Check if the phone number is provided; return error if null
      if (phone == null) {
        return Left("Phone number is required.");
      }

      // Check if the resend token is provided; return error if null
      if (resendToken == null) {
        return Left("Resend token is required.");
      }

      // Re-verify the phone number using the provided resend token
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone.phoneNumber, // The phone number to verify
        forceResendingToken:
            resendToken, // Force resending the verification code with the token
        verificationCompleted: (phoneAuthCredential) async {
          // This callback is triggered when verification is successfully completed
          final Either<String, User?> result =
              await signInWithCredential(phoneAuthCredential);

          result.fold(
            // If there's an error during sign-in, return the error message
            (error) {
              return Left(error);
            },
            // If user sign-in is successful, handle the authenticated user
            (user) async {
              UserModel model = UserModel.empty; // Create an empty user model

              if (user != null) {
                // Handle authenticated user (e.g., save user details in the system)
                await _userService.authenticatedUserHandler(
                  model.copyWith(
                    id: user.uid, // Set the user's ID
                    phone: phone, // Attach phone details to user model
                  ),
                );
              }
            },
          );
        },
        verificationFailed:
            verificationFailed, // Callback for verification failure
        codeSent: codeSent, // Callback for when the OTP code is sent
        codeAutoRetrievalTimeout:
            codeAutoRetrievalTimeout, // Callback for timeout
      );

      // Return success if the code is resent
      return Right(true);
    } catch (e) {
      // If any error occurs, handle it and return the error message
      final message = _firebaseAuthErrorUtil.handleException(e);
      return Left(message);
    }
  }

  /// Changes the user's phone number after verifying the SMS code.
  Future<Either<String, bool>> changePhoneNumber({
    required PhoneModel? newPhone, // The new phone model to be updated
    required String?
        verificationId, // The verification ID received during phone verification
    required String? smsCode, // The SMS code sent to the user for verification
  }) async {
    try {
      // Check if the new phone number is provided; return error if null
      if (newPhone == null) {
        return Left("Phone number is required.");
      }

      // Check if the verification ID or SMS code is missing or empty
      if (verificationId == null || smsCode == null || smsCode.isEmpty) {
        return Left("Missing verification ID or SMS code.");
      }

      // Create a PhoneAuthCredential using the verification ID and SMS code
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId:
            verificationId, // Verification ID received from Firebase
        smsCode: smsCode, // SMS code received by the user
      );

      // Check if there is a current user signed in; return error if null
      if (_currentUser == null) return Left('No user signed in.');

      // Update the user's phone number with the new credential
      await _currentUser?.updatePhoneNumber(credential);

      // Return success if the phone number is updated
      return Right(true);
    } catch (e) {
      // If any error occurs, handle it and return the error message
      final message = _firebaseAuthErrorUtil.handleException(e);
      return Left(message);
    }
  }

  /// Deletes the current signed-in user account.
  Future<Either<String, bool>> deleteAccount() async {
    try {
      // Check if there is a signed-in user; return error if no user is found
      if (_currentUser == null) return Left('No user signed in.');

      // Delete the user account from Firebase
      await _currentUser?.delete();

      // Return success if the account is deleted
      return Right(true);
    } catch (e) {
      // If any error occurs, handle it and return the error message
      final message = _firebaseAuthErrorUtil.handleException(e);
      return Left(message);
    }
  }

  /// Signs out the current user from Firebase.
  Future<Either<String, bool>> signOut() async {
    try {
      // Sign out the current user from Firebase
      await _firebaseAuth.signOut();

      // Return success if the user is signed out
      return Right(true);
    } catch (e) {
      // If any error occurs, handle it and return the error message
      final message = _firebaseAuthErrorUtil.handleException(e);
      return Left(message);
    }
  }

  /// Signs in the user using the provided phone auth credential.
  Future<Either<String, User?>> signInWithCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    try {
      // Sign in using the provided PhoneAuthCredential
      final UserCredential credential =
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);

      // Return the signed-in user
      return Right(credential.user);
    } catch (e) {
      // If any error occurs, handle it and return the error message
      final message = _firebaseAuthErrorUtil.handleException(e);
      return Left(message);
    }
  }
}
