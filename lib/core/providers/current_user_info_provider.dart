import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import 'user_service_provider.dart';

final currentUserInfoProvider = StreamProvider<UserModel>(
  (ref) {
    final UserService userService = ref.watch(userServiceProvider);
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Stream.error('User not logged in');
    }
    return userService.streamUser(userId).map(
          (either) => either.fold(
            (error) => throw error,
            (user) => user,
          ),
        );
  },
);
