import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../utils/user_util.dart';

final currentUserInfoProvider = StreamProvider<UserModel?>(
  (ref) {
    final UserService userService = UserService();

    final String? userId = UserUtil.currentUserId;

    if (userId == null) {
      return Stream.value(null);
    }

    return userService.streamUser(userId).map(
          (either) => either.fold(
            (error) => null,
            (user) => user,
          ),
        );
  },
);
