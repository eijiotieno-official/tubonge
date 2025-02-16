import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

import '../../../core/service/firestore_error_service.dart';
import '../model/auth_user.dart';
import 'auth_error_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final AuthErrorService _authErrorService;
  final FirestoreErrorService _firestoreErrorService;
  final GoogleSignIn _googleSignIn;
  final Logger _logger;

  AuthService(
    this._firebaseAuth,
    this._firestore,
    this._authErrorService,
    this._firestoreErrorService,
    this._googleSignIn,
    this._logger,
  );

  Stream<Either<String, bool>> get authStateChangesStream async* {
    try {
      _logger.i('Listening to auth state changes.');
      await for (final user in _firebaseAuth.authStateChanges()) {
        _logger
            .i('Auth state changed. User: ${user != null ? user.uid : "null"}');
        yield Right(user != null);
      }
    } catch (e) {
      final String errorMessage =
          _authErrorService.handleException(exception: e);
      _logger.e('Error listening to auth state changes: $errorMessage');
      yield Left(errorMessage);
    }
  }

  Future<Either<String, bool>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('Signing in with email: $email');
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      _logger.i('Sign-in successful. User ID: ${userCredential.user?.uid}');
      return Right(userCredential.user != null);
    } catch (e) {
      final String errorMessage =
          _authErrorService.handleException(exception: e);
      _logger.e('Error signing in with email: $errorMessage');
      return Left(errorMessage);
    }
  }

  Future<Either<String, bool>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('Signing up with email: $email');
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      _logger.i('Sign-up successful. User ID: ${userCredential.user?.uid}');
      return await _handleUserCreation(userCredential);
    } catch (e) {
      final String errorMessage =
          _authErrorService.handleException(exception: e);
      _logger.e('Error signing up with email: $errorMessage');
      return Left(errorMessage);
    }
  }

  Future<Either<String, bool>> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // For Flutter Web, use signInWithPopup
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email'); // Only request the email scope
        final UserCredential userCredential =
            await _firebaseAuth.signInWithPopup(googleProvider);

        return await _handleUserCreation(userCredential);
      } else {
        // For Android/iOS, proceed with Google Sign-In using GoogleSignIn plugin
        final GoogleSignInAccount? googleUserAccount =
            await _googleSignIn.signIn();

        // Check if the user aborted the sign-in
        if (googleUserAccount == null) {
          return Left('Google sign-in aborted by the user.');
        }

        // Retrieve the authentication information from Google
        final GoogleSignInAuthentication googleAuth =
            await googleUserAccount.authentication;

        // Create OAuthCredential using the access token and ID token
        final OAuthCredential googleAuthCredential =
            GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credentials
        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(googleAuthCredential);

        return await _handleUserCreation(userCredential);
      }
    } catch (e) {
      final String errorMessage =
          _authErrorService.handleException(exception: e);
      _logger.e('Error signing in with google: $errorMessage');
      return Left(errorMessage);
    }
  }

  Future<Either<String, bool>> sendPasswordResetEmail(String email) async {
    try {
      _logger.i('Sending password reset email to: $email');
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _logger.i('Password reset email sent to: $email');
      return const Right(true);
    } catch (e) {
      final String errorMessage =
          _authErrorService.handleException(exception: e);
      _logger.e('Error sending password reset email: $errorMessage');
      return Left(errorMessage);
    }
  }

  Future<Either<String, bool>> logout() async {
    try {
      _logger.i('Logging out user.');
      await _firebaseAuth.signOut();
      _logger.i('User logged out successfully.');
      return const Right(true);
    } catch (e) {
      final String errorMessage =
          _authErrorService.handleException(exception: e);
      _logger.e('Error logging out: $errorMessage');
      return Left(errorMessage);
    }
  }

  Future<Either<String, bool>> _checkIfUserIsNew(String userId) async {
    if (userId.isEmpty) {
      _logger.w('User ID is empty.');
      return Left('User ID cannot be empty.');
    }
    try {
      _logger.i('Checking if user is new. User ID: $userId');
      final DocumentSnapshot userDocument =
          await _firestore.collection('users').doc(userId).get();
      final isNewUser = !userDocument.exists;
      _logger.i('Is new user: $isNewUser');
      return Right(isNewUser);
    } catch (e) {
      final String errorMessage = _firestoreErrorService.handleException(e);
      _logger.e('Error checking if user is new: $errorMessage');
      return Left(errorMessage);
    }
  }

  Future<Either<String, bool>> _createUserDocument(AuthUser authUser) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;

      if (currentUser == null) {
        _logger.w('No user is currently signed in.');
        return Left('No user is currently signed in.');
      }

      final DocumentReference userDocumentRef =
          _firestore.collection('users').doc(currentUser.uid);

      _logger.i('Creating user document for User ID: ${currentUser.uid}');
      await userDocumentRef.set(authUser.toMap());
      _logger.i('User document created successfully.');
      return Right(true);
    } catch (e) {
      final String errorMessage = _firestoreErrorService.handleException(e);
      _logger.e('Error creating user document: $errorMessage');
      return Left(errorMessage);
    }
  }

  Future<Either<String, bool>> _handleUserCreation(
      UserCredential userCredential) async {
    final userId = _firebaseAuth.currentUser?.uid;

    if (userId == null) {
      _logger.w('No user is currently signed in.');
      return Left('No user is currently signed in.');
    }

    _logger.i('Handling user creation. User ID: $userId');
    final isNewUserResult = await _checkIfUserIsNew(userId);

    return isNewUserResult.fold(
      (error) {
        _logger.e('Error in user creation check: $error');
        return Left(error);
      },
      (isNewUser) async {
        if (isNewUser) {
          _logger.i('User is new. Creating user document.');
          final createUserResult = await _createUserDocument(
            AuthUser(
              id: userId,
              email: userCredential.user?.email ?? '',
            ),
          );

          return createUserResult.fold(
            (error) {
              _logger.e('Error creating user document: $error');
              return Left(error);
            },
            (_) {
              _logger.i('User creation process completed successfully.');
              return Right(true);
            },
          );
        } else {
          _logger.i('User already exists. No further action needed.');
          return Right(true);
        }
      },
    );
  }
}
