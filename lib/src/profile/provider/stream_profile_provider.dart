import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/profile_model.dart';
import 'profile_service_provider.dart';

final streamProfileProvider =
    StreamProvider.autoDispose.family<AsyncValue<Profile>, String>(
  (ref, userId) {
    final profileService = ref.watch(profileServiceProvider);

    final profileStream = profileService.streamSpecific(userId);

    return profileStream.map(
      (either) => either.fold(
        (error) => AsyncValue.error(error, StackTrace.current),
        (profile) => AsyncValue.data(profile),
      ),
    );
  },
);
