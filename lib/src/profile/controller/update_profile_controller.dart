import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/profile_model.dart';
import '../provider/profile_service_provider.dart';
import '../service/profile_service.dart';

class UpdateProfileController extends StateNotifier<AsyncValue<bool>> {
  final ProfileService _profileService;
  UpdateProfileController(this._profileService) : super(AsyncValue.data(false));

  Future<void> call(Profile profile) async {
    state = AsyncValue.loading();

    final result = await _profileService.update(profile);

    state = result.fold(
      (error) => AsyncValue.error(
        error,
        StackTrace.current,
      ),
      (success) => AsyncValue.data(success),
    );
  }
}

final updateProfileProvider =
    StateNotifierProvider<UpdateProfileController, AsyncValue<bool>>(
  (ref) {
    final profileService = ref.watch(profileServiceProvider);
    return UpdateProfileController(profileService);
  },
);
