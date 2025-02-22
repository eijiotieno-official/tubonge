import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/profile_model.dart';
import 'profile_service_provider.dart';

final currentUserProfileProvider = StreamProvider.autoDispose<AsyncValue<Profile>>(
  (ref) async* {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId != null) {
      final profileService = ref.watch(profileServiceProvider);

      final profileStream = profileService.streamSpecific(currentUserId);

      await for (final either in profileStream) {
        yield either.fold(
          (error) => AsyncValue.error(error, StackTrace.current),
          (profile) => AsyncValue.data(profile),
        );
      }
    } else {
      yield AsyncValue.data(Profile.empty);
    }
  },
);
