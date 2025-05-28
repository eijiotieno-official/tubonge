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
      if (model.id.isEmpty) {
        return Left('Invalid user ID');
      }

      final userDoc = await UserUtil.users.doc(model.id).get();
      final isNewUser = !userDoc.exists;

      return isNewUser
          ? await _createUser(model)
          : await _updateExistingUser(
              model, UserModel.fromMap(userDoc.data() as Map<String, dynamic>));
    } catch (e) {
      final errorMessage = _firestoreErrorUtil.handleException(e);
      return Left(errorMessage);
    }
  }

  
  Future<Either<String, UserModel>> _createUser(UserModel model) async {
    try {
      final tokenResult = await _getFCMToken();
      if (!tokenResult.isRight()) {
        return Left('Failed to fetch FCM token');
      }

      final token = tokenResult.getOrElse(() => '');
      final updatedModel = model.copyWith(tokens: [token]);
      await UserUtil.users.doc(model.id).set(updatedModel.toMap());

      return Right(updatedModel);
    } catch (e) {
      return Left('Error during user creation: $e');
    }
  }

  
  Future<Either<String, String>> _getFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        return Left('FCM token is null');
      }
      return Right(token);
    } catch (e) {
      return Left('Error fetching FCM token: $e');
    }
  }

  
  Future<Either<String, UserModel>> _updateExistingUser(
    UserModel model,
    UserModel existingModel,
  ) async {
    try {
      final tokenResult = await _getFCMToken();
      if (!tokenResult.isRight()) {
        return Left('Failed to fetch FCM token');
      }

      final newToken = tokenResult.getOrElse(() => '');
      final existingTokens = List<String>.from(existingModel.tokens);

      if (newToken.isNotEmpty && !existingTokens.contains(newToken)) {
        existingTokens.add(newToken);
        model = model.copyWith(tokens: existingTokens);
      }

      await UserUtil.users.doc(model.id).update(model.toMap());
      return Right(model);
    } catch (e) {
      return Left('Error updating existing user: $e');
    }
  }

  
  Stream<Either<String, UserModel>> streamUser(String userId) {
    if (userId.isEmpty) {
      return Stream.value(Left('Invalid user ID'));
    }

    return UserUtil.users
        .doc(userId)
        .snapshots()
        .map<Either<String, UserModel>>((docSnapshot) {
      if (!docSnapshot.exists) {
        return Left('User not found.');
      }

      try {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return Right(UserModel.fromMap(data));
      } catch (e) {
        return Left('Error parsing user data: $e');
      }
    }).handleError((error) => Left('Stream error: $error'));
  }
}
