import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/user_service_provider.dart';
import '../service/firebase_auth_service.dart';
import '../util/firebase_auth_error_util.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  final firebaseAuth = FirebaseAuth.instance;

  final firebaseAuthErrorUtil = FirebaseAuthErrorUtil();

  final userService = ref.watch(userServiceProvider);

  return FirebaseAuthService(
    firebaseAuth: firebaseAuth,
    firebaseAuthErrorUtil: firebaseAuthErrorUtil,
    userService: userService,
  );
});
