import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/profile_model.dart';
import 'profile_service_provider.dart';

final currentUserProfileProvider = StreamProvider.autoDispose<Profile>(
  (ref) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId != null) {
      final profileService = ref.watch(profileServiceProvider);

      final profileStream = profileService.streamSpecific(currentUserId);

      return profileStream.map(
        (either) => either.fold(
          (error) => throw error,
          (profile) => profile,
        ),
      );
    }

    return Stream.value(Profile.empty);
  },
);
