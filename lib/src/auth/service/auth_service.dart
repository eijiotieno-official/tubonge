import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/service/auth_error_service.dart';
import '../../../core/service/firestore_error_service.dart';
import '../model/auth_user.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthErrorService _authErrorService = AuthErrorService();
  final FirestoreErrorService _firestoreErrorService = FirestoreErrorService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        "1025584618741-2he44irob6nj4oc23cjqe5043irl6gv6.apps.googleusercontent.com",
    scopes: <String>[
      'email',
    ],
  );

  Stream<Either<String, bool>> get authStateChangesStream async* {
    try {
      await for (final user in _firebaseAuth.authStateChanges()) {
        yield Right(user != null);
      }
    } catch (e) {
      final String errorMessage =
          _authErrorService.handleException(exception: e);
      yield Left(errorMessage);
    }
  }

  Future<Either<String, bool>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return Right(userCredential.user != null);
    } catch (e) {
      final String errorMessage =
          _authErrorService.handleException(exception: e);
      return Left(errorMessage);
    }
  }

  Future<Either<String, bool>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return await _handleUserCreation(userCredential);
    } catch (e) {
      final String errorMessage =
          _authErrorService.handleException(exception: e);
      return Left(errorMessage);
    }
  }

  Future<Either<String, bool>> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        final UserCredential userCredential =
            await _firebaseAuth.signInWithPopup(googleProvider);
        return await _handleUserCreation(userCredential);
      } else {
        final GoogleSignInAccount? googleUserAccount =
            await _googleSignIn.signIn();
        if (googleUserAccount == null) {
          return Left('Google sign-in aborted by the user.');
        }
        final GoogleSignInAuthentication googleAuth =
            await googleUserAccount.authentication;
        final OAuthCredential googleAuthCredential =
            GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(googleAuthCredential);
        return await _handleUserCreation(userCredential);
      }
    } catch (e) {
      final String errorMessage =
          _authErrorService.handleException(exception: e);
      return Left(errorMessage);
    }
  }

  Future<Either<String, bool>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(true);
    } catch (e) {
      final String errorMessage =
          _authErrorService.handleException(exception: e);
      return Left(errorMessage);
    }
  }

  Future<Either<String, bool>> logout() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(true);
    } catch (e) {
      final String errorMessage =
          _authErrorService.handleException(exception: e);
      return Left(errorMessage);
    }
  }

  Future<Either<String, bool>> _checkIfUserIsNew(String userId) async {
    if (userId.isEmpty) {
      return Left('User ID cannot be empty.');
    }
    try {
      final DocumentSnapshot userDocument =
          await _firestore.collection('users').doc(userId).get();
      return Right(!userDocument.exists);
    } catch (e) {
      final String errorMessage = _firestoreErrorService.handleException(e);
      return Left(errorMessage);
    }
  }

  Future<Either<String, bool>> _createUserDocument(AuthUser authUser) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return Left('No user is currently signed in.');
      }
      final DocumentReference userDocumentRef =
          _firestore.collection('users').doc(currentUser.uid);
      await userDocumentRef.set(authUser.toMap());
      return Right(true);
    } catch (e) {
      final String errorMessage = _firestoreErrorService.handleException(e);
      return Left(errorMessage);
    }
  }

  Future<Either<String, bool>> _handleUserCreation(
      UserCredential userCredential) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      return Left('No user is currently signed in.');
    }
    final isNewUserResult = await _checkIfUserIsNew(userId);
    return isNewUserResult.fold(
      (error) => Left(error),
      (isNewUser) async {
        if (isNewUser) {
          final createUserResult = await _createUserDocument(
            AuthUser(
              id: userId,
              email: userCredential.user?.email ?? '',
            ),
          );
          return createUserResult;
        } else {
          return Right(true);
        }
      },
    );
  }
}
