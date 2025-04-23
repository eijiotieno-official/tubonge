import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/user_model.dart';
import '../utils/firestore_error_util.dart';
import '../utils/user_util.dart';

/// A service class responsible for handling user authentication and Firestore operations.
class UserService {
  final FirestoreErrorUtil _firestoreErrorUtil;

  UserService({
    required FirestoreErrorUtil firestoreErrorUtil,
  }) : _firestoreErrorUtil = firestoreErrorUtil;

  /// Determines if the user is new or existing and handles accordingly.
  Future<Either<String, UserModel>> authenticatedUserHandler(
      UserModel model) async {
    try {
      final isNewUserResult = await _checkIfNewUser(model.id);

      // Handle the user based on whether they're new or existing
      return isNewUserResult.fold(
        (error) => Left(error),
        (isNewUser) async => isNewUser
            ? await _handleNewUser(model) // Create new user
            : await _handleExistingUser(model), // Update existing user
      );
    } catch (e) {
      final errorMessage = _firestoreErrorUtil.handleException(e);
      return Left(errorMessage);
    }
  }

  /// Checks if the user exists in the Firestore collection.
  Future<Either<String, bool>> _isNewUser(String userId) async {
    try {
      final userDoc = await UserUtil.users.doc(userId).get();
      final isNew = !userDoc.exists; // User is new if doc doesn't exist
      return Right(isNew);
    } catch (e) {
      return Left('Error while checking if user is new: $e');
    }
  }

  /// A wrapper around _isNewUser to ensure uniform error/result handling.
  Future<Either<String, bool>> _checkIfNewUser(String userId) async {
    final isNewUserResult = await _isNewUser(userId);
    return isNewUserResult.fold(
      (error) => Left(error),
      (isNewUser) => Right(isNewUser),
    );
  }

  /// Creates a new user document in Firestore.
  Future<Either<String, UserModel>> _createUser(UserModel model) async {
    try {
      UserModel updatedModel = model;
      final documentReference = UserUtil.users.doc(model.id);

      final tokenResult = await _getFCMToken();
      if (tokenResult.isRight()) {
        // Assign FCM token to the user model
        updatedModel = updatedModel.copyWith(
          tokens: [tokenResult.getOrElse(() => '')],
        );
      } else {
        return Left('Failed to fetch FCM token');
      }

      // Save the new user to Firestore
      await documentReference.set(updatedModel.toMap());
      return Right(updatedModel);
    } catch (e) {
      return Left('Error during user creation: $e');
    }
  }

  /// Handles logic for a new user (e.g., first-time sign-in).
  Future<Either<String, UserModel>> _handleNewUser(UserModel model) async {
    final createResult = await _createUser(model);
    return createResult.fold(
      (error) => Left(error),
      (updatedModel) => Right(updatedModel),
    );
  }

  /// Retrieves the FCM token used for push notifications.
  Future<Either<String, String>> _getFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      return token != null ? Right(token) : Left('FCM token is null');
    } catch (e) {
      return Left('Error fetching FCM token: $e');
    }
  }

  /// Handles logic for an existing user (e.g., updating tokens).
  Future<Either<String, UserModel>> _handleExistingUser(UserModel model) async {
    final tokenResult = await _getFCMToken();

    return tokenResult.fold(
      (error) => Left(error),
      (newToken) async {
        final userDoc = await UserUtil.users.doc(model.id).get();
        if (!userDoc.exists) {
          return Left('User does not exist.');
        }

        // Deserialize existing user data
        final userModel =
            UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

        // Update user data with new token if needed
        return await _updateExistingUser(model, userModel, newToken);
      },
    );
  }

  /// Updates the user's document in Firestore.
  Future<Either<String, UserModel>> _updateUser(UserModel model) async {
    try {
      final userDoc = await UserUtil.users.doc(model.id).get();
      if (!userDoc.exists) {
        return Left('User does not exist.');
      }

      // Write updated user data to Firestore
      await UserUtil.users.doc(model.id).update(model.toMap());
      return Right(model);
    } catch (e) {
      return Left('Error while updating user: $e');
    }
  }

  /// Updates the existing user model with a new token if necessary.
  Future<Either<String, UserModel>> _updateExistingUser(
    UserModel model,
    UserModel userModel,
    String newToken,
  ) async {
    final existingTokens = List<String>.from(userModel.tokens);

    // Add new token only if it isn't already present
    if (newToken.isNotEmpty && !existingTokens.contains(newToken)) {
      existingTokens.add(newToken);
      model = model.copyWith(tokens: existingTokens);
    }

    final updateResult = await _updateUser(model);

    return updateResult.fold(
      (error) => Left(error),
      (updatedModel) => Right(updatedModel),
    );
  }

  /// Streams updates to the user document in real time.
  Stream<Either<String, UserModel>> streamUser(String userId) {
    return UserUtil.users
        .doc(userId)
        .snapshots()
        .map<Either<String, UserModel>>((docSnapshot) {
      if (docSnapshot.exists) {
        try {
          final data = docSnapshot.data() as Map<String, dynamic>;
          final userModel = UserModel.fromMap(data);
          return Right(userModel);
        } catch (e) {
          return Left('Error parsing user data: $e');
        }
      } else {
        return Left('User not found.');
      }
    }).handleError((error) {
      // Capture any unexpected stream errors
      return Left('Stream error: $error');
    });
  }
}
