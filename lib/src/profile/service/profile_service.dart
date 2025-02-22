import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../core/service/firestore_error_service.dart';
import '../model/profile_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreErrorService _firestoreErrorService = FirestoreErrorService();

  CollectionReference get _usersCollection => _firestore.collection("users");

  Stream<Either<String, Profile>> streamSpecific(String userId) {
    return _usersCollection
        .doc(userId)
        .snapshots()
        .asyncMap<Either<String, Profile>>(
      (onData) {
        if (!onData.exists) {
          return Left("User not found");
        }

        final map = onData.data() as Map<String, dynamic>;
        final profile = Profile.fromMap(map);
        return Right(profile);
      },
    ).handleError(
      (error) {
        final message = _firestoreErrorService.handleException(error);
        return Left(message);
      },
    );
  }

  Future<Either<String, bool>> update(Profile profile) async {
    try {
      await _usersCollection.doc(profile.id).update(profile.toMap());

      return Right(true);
    } catch (e) {
      final message = _firestoreErrorService.handleException(e);
      return Left(message);
    }
  }
}
