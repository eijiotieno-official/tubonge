import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/service/firestore_error_service.dart';
import '../service/auth_error_service.dart';
import '../service/auth_service.dart';
import 'google_sign_in_provider.dart';

final authServiceProvider = Provider<AuthService>(
  (ref) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    AuthErrorService authErrorService = AuthErrorService();
    FirestoreErrorService firestoreErrorService = FirestoreErrorService();
    Logger logger = Logger();
    final googleSignIn = ref.watch(googleSignInProvider);

    return AuthService(
      firebaseAuth,
      firestore,
      authErrorService,
      firestoreErrorService,
      googleSignIn,
      logger,
    );
  },
);
