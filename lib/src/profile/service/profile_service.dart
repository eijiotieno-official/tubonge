import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

import '../../../core/service/firestore_error_service.dart';
import '../model/profile_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore;
  final FirestoreErrorService _firestoreErrorService;
  final Logger _logger;

  ProfileService(
    this._firestore,
    this._firestoreErrorService,
    this._logger,
  );

  Stream<Either<String, Profile>> streamSpecific(String userId) {
    _logger.i('Starting profile stream for user ID: $userId');

    return _firestore
        .collection("users")
        .doc(userId)
        .snapshots()
        .asyncMap<Either<String, Profile>>(
      (onData) {
        if (onData.exists == false) {
          return Left("User not found");
        }

        _logger.i('Received profile snapshot for user ID: $userId');

        final map = onData.data() as Map<String, dynamic>;

        _logger.i('Map data: $map');

        final profile = Profile.fromMap(map);

        _logger.i('Profile data parsed successfully: $profile');

        return Right(profile);
      },
    ).handleError(
      (error) {
        _logger.e('Error in profile stream for user ID: $userId', error: error);
        final message = _firestoreErrorService.handleException(error);
        return Left(message);
      },
    );
  }

  Future<Either<String, bool>> update(Profile profile) async {
    try {
      _logger.i('Updating profile for user ID: ${profile.id}');

      await _firestore
          .collection("users")
          .doc(profile.id)
          .update(profile.toMap());

      _logger.i('Profile updated successfully for user ID: ${profile.id}');
      return Right(true);
    } catch (e) {
      _logger.e('Error updating profile for user ID: ${profile.id}', error: e);
      final message = _firestoreErrorService.handleException(e);
      return Left(message);
    }
  }
}
