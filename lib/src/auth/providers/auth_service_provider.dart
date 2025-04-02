import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/user_service_provider.dart';
import '../../../core/services/user_service.dart';
import '../services/auth_error_service.dart';
import '../services/auth_service.dart';
import 'auth_error_service_provider.dart';


final authServiceProvider = Provider<AuthService>((ref) {
  final UserService userService = ref.watch(userServiceProvider);
  final FirebaseAuth auth = FirebaseAuth.instance;
  final AuthErrorService authErrorService = ref.watch(authErrorServiceProvider);
  return AuthService(
    userService: userService,
    auth: auth,
    authErrorService: authErrorService,
  );
});



