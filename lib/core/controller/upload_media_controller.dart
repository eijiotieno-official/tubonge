import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum representing upload states
enum MediaUploadState {
  none,
  uploading,
  success,
  failed,
  canceled,
  paused,
}

class MediaUpload {
  final PlatformFile? file;
  final String? downloadUrl;
  final double progress;
  final MediaUploadState state;

  MediaUpload({
    this.file,
    this.downloadUrl,
    required this.progress,
    required this.state,
  });

  MediaUpload copyWith({
    PlatformFile? file,
    String? downloadUrl,
    double? progress,
    MediaUploadState? state,
  }) {
    return MediaUpload(
      file: file ?? this.file,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      progress: progress ?? this.progress,
      state: state ?? this.state,
    );
  }

  static MediaUpload get empty => MediaUpload(
        progress: 0.0,
        state: MediaUploadState.none,
      );
}

class UploadMediaController extends StateNotifier<AsyncValue<MediaUpload>> {
  final FirebaseStorage _firebaseStorage;
  UploadTask? _uploadTask;

  UploadMediaController(this._firebaseStorage, PlatformFile? file)
      : super(AsyncValue.data(MediaUpload.empty.copyWith(file: file)));

  Future<void> upload() async {
    final file = state.valueOrNull?.file;

    if (file == null || file.bytes == null) {
      state = AsyncValue.error("File not supported", StackTrace.current);
      return;
    }

    final storageRef = _firebaseStorage.ref().child('media/${file.name}');

    try {
      _uploadTask = storageRef.putData(file.bytes!);

      _uploadTask?.snapshotEvents.listen(
        (TaskSnapshot snapshot) async {
          final progress = snapshot.totalBytes > 0
              ? snapshot.bytesTransferred / snapshot.totalBytes
              : 0.0;

          state = AsyncValue.data(
            state.valueOrNull!.copyWith(
              progress: progress,
              state: progress > 0.0 && progress < 1.0
                  ? MediaUploadState.uploading
                  : MediaUploadState.none,
            ),
          );

          switch (snapshot.state) {
            case TaskState.success:
              final downloadUrl = await storageRef.getDownloadURL();
              state = AsyncValue.data(
                state.valueOrNull!.copyWith(
                  downloadUrl: downloadUrl,
                  state: MediaUploadState.success,
                ),
              );
              break;

            case TaskState.error:
              state = AsyncValue.data(
                state.valueOrNull!.copyWith(state: MediaUploadState.failed),
              );
              break;

            case TaskState.canceled:
              state = AsyncValue.data(
                state.valueOrNull!.copyWith(state: MediaUploadState.canceled),
              );
              break;

            case TaskState.paused:
              state = AsyncValue.data(
                state.valueOrNull!.copyWith(state: MediaUploadState.paused),
              );
              break;

            default:
              break;
          }
        },
        onError: (e) {
          state = AsyncValue.error(e, StackTrace.current);
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Pause Upload
  void pauseUpload() {
    if (_uploadTask != null &&
        state.valueOrNull?.state == MediaUploadState.uploading) {
      _uploadTask?.pause();
      state = AsyncValue.data(
          state.valueOrNull!.copyWith(state: MediaUploadState.paused));
    }
  }

  // Resume Upload
  void resumeUpload() {
    if (_uploadTask != null &&
        state.valueOrNull?.state == MediaUploadState.paused) {
      _uploadTask?.resume();
      state = AsyncValue.data(
          state.valueOrNull!.copyWith(state: MediaUploadState.uploading));
    }
  }

  // Cancel Upload
  void cancelUpload() {
    if (_uploadTask != null &&
        (state.valueOrNull?.state == MediaUploadState.uploading ||
            state.valueOrNull?.state == MediaUploadState.paused)) {
      _uploadTask?.cancel();
      state = AsyncValue.data(
          state.valueOrNull!.copyWith(state: MediaUploadState.canceled));
    }
  }
}

// Family Provider for UploadMediaController using PlatformFile
final uploadMediaProvider = StateNotifierProvider.family<UploadMediaController,
    AsyncValue<MediaUpload>, PlatformFile?>(
  (ref, file) => UploadMediaController(FirebaseStorage.instance, file),
);
