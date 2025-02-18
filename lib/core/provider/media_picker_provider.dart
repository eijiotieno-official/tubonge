import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/media_picker_service.dart';

class MediaPickerNotifier
    extends StateNotifier<AsyncValue<List<PlatformFile>>> {
  final MediaPickerService _mediaPickerService;
  MediaPickerNotifier(this._mediaPickerService) : super(AsyncValue.data([]));

  Future<void> call({
    int maxCount = 1,
    required FileType type,
  }) async {
    state = AsyncValue.loading();

    final result =
        await _mediaPickerService.openPicker(type: type, maxCount: maxCount);

    state = result.fold(
      (error) => AsyncValue.error(error, StackTrace.current),
      (success) => AsyncValue.data(success),
    );
  }

  void clear() {
    state = AsyncValue.data([]);
  }
}

final filePickerProvider =
    StateNotifierProvider<MediaPickerNotifier, AsyncValue<List<PlatformFile>>>(
  (ref) {
    final mediaPickerService = MediaPickerService();
    return MediaPickerNotifier(mediaPickerService);
  },
);
