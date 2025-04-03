import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/user_model.dart';
import '../utils/firestore_error_util.dart';
import '../utils/user_util.dart';

class UserService {
  final FirestoreErrorUtil _firestoreErrorUtil;
  UserService({
    required FirestoreErrorUtil firestoreErrorUtil,
  }) : _firestoreErrorUtil = firestoreErrorUtil;

  
  Future<Either<String, UserModel>> authenticatedUserHandler(
      UserModel model) async {
    try {
      final isNewUserResult = await _checkIfNewUser(model.id);

      return isNewUserResult.fold(
        (error) => Left(error),
        (isNewUser) async => isNewUser
            ? await _handleNewUser(model)
            : await _handleExistingUser(model),
      );
    } catch (e) {
      final errorMessage = _firestoreErrorUtil.handleException(e);
      return Left(errorMessage);
    }
  }

  Future<Either<String, bool>> _isNewUser(String userId) async {
    try {
      // Fetch the user document from Firestore
      final userDoc = await UserUtil.users.doc(userId).get();

      // Check if the document exists
      final isNew = !userDoc.exists;
      return Right(isNew);
    } catch (e) {
      // Return an error message if an exception occurs
      return Left('Error while checking if user is new: $e');
    }
  }

  Future<Either<String, bool>> _checkIfNewUser(String userId) async {
    final isNewUserResult = await _isNewUser(userId);
    return isNewUserResult.fold(
      (error) => Left(error),
      (isNewUser) => Right(isNewUser),
    );
  }

  Future<Either<String, UserModel>> _createUser(UserModel model) async {
    try {
      UserModel updatedModel = model;
      final documentReference = UserUtil.users.doc(model.id);

      final tokenResult = await _getFCMToken();
      if (tokenResult.isRight()) {
        // Update the user model with the FCM token
        updatedModel =
            updatedModel.copyWith(tokens: [tokenResult.getOrElse(() => '')]);
      } else {
        // Return an error if FCM token fetch fails
        return Left('Failed to fetch FCM token');
      }

      // Save the updated user model to Firestore
      await documentReference.set(updatedModel.toMap());
      return Right(updatedModel);
    } catch (e) {
      // Return an error message if an exception occurs
      return Left('Error during user creation: $e');
    }
  }

  Future<Either<String, UserModel>> _handleNewUser(UserModel model) async {
    final createResult = await _createUser(model);
    return createResult.fold(
      (error) => Left(error),
      (updatedModel) => Right(updatedModel),
    );
  }

  Future<Either<String, String>> _getFCMToken() async {
    try {
      // Fetch the FCM token
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        return Right(token);
      } else {
        return Left('FCM token is null');
      }
    } catch (e) {
      // Return an error message if an exception occurs
      return Left('Error fetching FCM token: $e');
    }
  }

  Future<Either<String, UserModel>> _handleExistingUser(UserModel model) async {
    final tokenResult = await _getFCMToken();

    return tokenResult.fold(
      (error) => Left(error),
      (newToken) async {
        final userDoc = await UserUtil.users.doc(model.id).get();
        if (!userDoc.exists) {
          return Left('User does not exist.');
        }

        final userModel =
            UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        return await _updateExistingUser(model, userModel, newToken);
      },
    );
  }

  Future<Either<String, UserModel>> _updateUser(UserModel model) async {
    try {
      // Check if the user document exists
      final userDoc = await UserUtil.users.doc(model.id).get();
      if (!userDoc.exists) {
        return Left('User does not exist.');
      }

      // Update the user document in Firestore
      await UserUtil.users.doc(model.id).update(model.toMap());
      return Right(model);
    } catch (e) {
      // Return an error message if an exception occurs
      return Left('Error while updating user: $e');
    }
  }

  Future<Either<String, UserModel>> _updateExistingUser(
      UserModel model, UserModel userModel, String newToken) async {
    final existingTokens = List<String>.from(userModel.tokens);
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
          final errorMsg = 'Error parsing user data: $e';
          return Left(errorMsg);
        }
      } else {
        return Left('User not found.');
      }
    }).handleError((error) {
      return Left('Stream error: $error');
    });
  }
}
