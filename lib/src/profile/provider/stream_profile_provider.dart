import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/profile_model.dart';
import 'profile_service_provider.dart';

final streamProfileProvider =
    StreamProvider.autoDispose.family<Profile, String?>(
  (ref, userId) {
    
    if (userId == null) {
      return throw "User not found";
    }

    final profileService = ref.watch(profileServiceProvider);
    final profileStream = profileService.streamSpecific(userId);

    return profileStream.map(
      (either) => either.fold(
        (error) => throw error,
        (profile) => profile,
      ),
    );
  },
);
