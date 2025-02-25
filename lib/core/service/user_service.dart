import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tubonge/core/widget/users_list_view.dart';

import '../../src/profile/model/profile_model.dart';
import 'firestore_error_service.dart';

class UserService {
  CollectionReference get _usersCollection =>
      FirebaseFirestore.instance.collection('users');

  final FirestoreErrorService _firestoreErrorService = FirestoreErrorService();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get _currentUser => _firebaseAuth.currentUser;

  Stream<Either<String, List<Profile>>> streamUsers() {
    return _usersCollection
        .where('id', isNotEqualTo: _currentUser?.uid)
        .snapshots()
        .map<Either<String, List<Profile>>>(
      (querySnapshot) {
        try {
          final users = querySnapshot.docs
              .map((doc) => Profile.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
          return Right(users);
        } catch (e) {
          return Left(
              'Failed to fetch users: ${_firestoreErrorService.handleException(e)}');
        }
      },
    ).handleError(
      (error) {
        return Left(
            'Firestore stream error: ${_firestoreErrorService.handleException(error)}');
      },
    );
  }

  Future<void> showUsersDialog(BuildContext context) async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => UsersListView(),
    );
  }
}
