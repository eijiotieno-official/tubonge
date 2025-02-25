import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../src/profile/model/profile_model.dart';
import 'user_service_provider.dart';

final usersProvider = StreamProvider<List<Profile>>(
  (ref) {
    final userService = ref.watch(userServiceProvider);
    final streamResult = userService.streamUsers();

    return streamResult.map(
      (either) => either.fold(
        (error) => throw error,
        (users) => users,
      ),
    );
  },
);
