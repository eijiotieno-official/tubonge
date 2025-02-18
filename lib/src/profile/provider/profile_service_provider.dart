import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/service/firestore_error_service.dart';
import '../service/profile_service.dart';

final profileServiceProvider = Provider<ProfileService>(
  (ref) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirestoreErrorService firestoreErrorService = FirestoreErrorService();
    Logger logger = Logger();

    return ProfileService(
      firestore,
      firestoreErrorService,
      logger,
    );
  },
);
