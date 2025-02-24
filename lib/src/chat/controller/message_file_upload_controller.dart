import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../models/message_model.dart';
import '../service/message_service.dart';

enum MessageFileUploadState {
  none,
  uploading,
  paused,
  success,
  failed,
  canceled,
}

class MessageFileUpload {
  final String? id;
  final PlatformFile? file;
  final String? downloadUrl;
  final double progress;
  final MessageFileUploadState state;

  MessageFileUpload({
    this.id,
    this.file,
    this.downloadUrl,
    required this.progress,
    required this.state,
  });

  static MessageFileUpload empty() => MessageFileUpload(
        progress: 0.0,
        state: MessageFileUploadState.none,
      );

  MessageFileUpload copyWith({
    String? id,
    PlatformFile? file,
    String? downloadUrl,
    double? progress,
    MessageFileUploadState? state,
  }) {
    return MessageFileUpload(
      id: id ?? this.id,
      file: file ?? this.file,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      progress: progress ?? this.progress,
      state: state ?? this.state,
    );
  }
}

class MessageFileUploadController extends StateNotifier<MessageFileUpload> {
  final MessageService _messageService;

  MessageFileUploadController(this._messageService)
      : super(MessageFileUpload.empty());

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final Logger _logger = Logger();

  UploadTask? _uploadTask;

  void upload(Message message) {
    PlatformFile? file;

    // Step 1: Create PlatformFile from the message URI
    if (message is ImageMessage) {
      file = PlatformFile(
        name: message.imageUri.split('/').last,
        size: File(message.imageUri).lengthSync(),
        path: message.imageUri,
      );
      _logger.i(
          "ImageMessage detected. File created with Name: ${file.name}, Size: ${file.size} bytes, Path: ${file.path}");
    } else if (message is VideoMessage) {
      file = PlatformFile(
        name: message.videoUri.split('/').last,
        size: File(message.videoUri).lengthSync(),
        path: message.videoUri,
      );
      _logger.i(
          "VideoMessage detected. File created with Name: ${file.name}, Size: ${file.size} bytes, Path: ${file.path}");
    } else {
      _logger.w("Unsupported message type for file upload.");
    }

    // Step 2: Update state with selected file and message ID
    state = state.copyWith(
      id: message.id,
      file: file,
    );
    _logger.i(
        'Starting upload for file: ${file?.path} with Message ID: ${message.id}');

    if (file != null && file.path != null) {
      try {
        // Step 3: Create a Firebase Storage reference
        final ref = _firebaseStorage.ref().child('uploads/${message.id}');
        _logger
            .i("Firebase Storage reference created at path: ${ref.fullPath}");

        // Step 4: Initiate the upload task (convert PlatformFile to File)
        _uploadTask = ref.putFile(File(file.path!));
        _logger.i("Upload task initiated for file at path: ${file.path}");

        // Step 5: Listen to upload progress
        _uploadTask?.snapshotEvents.listen(
          (TaskSnapshot snapshot) async {
            final progress = snapshot.bytesTransferred / snapshot.totalBytes;
            _logger.d(
                'Snapshot state: ${snapshot.state}, Progress: ${(progress * 100).toStringAsFixed(2)}%');

            state = state.copyWith(
              progress: progress,
              state: (progress > 0.0 && progress < 1.0)
                  ? MessageFileUploadState.uploading
                  : MessageFileUploadState.none,
            );

            // Step 6: Handle different task states
            switch (snapshot.state) {
              case TaskState.success:
                _logger.i("Upload succeeded. Retrieving download URL...");
                final downloadUrl = await ref.getDownloadURL();
                _logger.i("Download URL retrieved: $downloadUrl");
                state = state.copyWith(
                  downloadUrl: downloadUrl,
                  state: MessageFileUploadState.success,
                );
                // Update the message with the new URL
                _updateMessage(
                  message: message,
                  url: downloadUrl,
                  file: file,
                );
                break;
              case TaskState.error:
                _logger.e("Upload encountered an error.");
                state = state.copyWith(state: MessageFileUploadState.failed);
                break;
              case TaskState.canceled:
                _logger.w("Upload was canceled.");
                state = state.copyWith(state: MessageFileUploadState.canceled);
                break;
              case TaskState.paused:
                _logger.w("Upload is paused.");
                state = state.copyWith(state: MessageFileUploadState.paused);
                break;
              default:
                _logger.d("Upload task in an unhandled state.");
            }
          },
          onError: (e) {
            _logger.e('Error during upload task: $e');
            state = state.copyWith(state: MessageFileUploadState.failed);
          },
        );
      } catch (e) {
        _logger.e('Exception during file upload: $e');
        state = state.copyWith(state: MessageFileUploadState.failed);
      }
    } else {
      _logger.w(
          "No file available for upload. File is null or file.path is null.");
    }
  }

  void _updateMessage({
    required Message message,
    required String url,
    required PlatformFile? file,
  }) {
    if (file == null) {
      _logger.w("No file available in _updateMessage. Aborting update.");
      return;
    }

    if (message is ImageMessage) {
      _logger.i("Updating ImageMessage with new URL: $url");
      _messageService.updateMessage(message.copyWith(imageUri: url));
    } else if (message is VideoMessage) {
      _logger.i("Updating VideoMessage with new URL: $url");
      _messageService.updateMessage(message.copyWith(videoUri: url));
    } else {
      _logger.w("Unsupported message type in _updateMessage.");
    }
  }

  void pause() {
    if (_uploadTask != null &&
        state.state == MessageFileUploadState.uploading) {
      _uploadTask?.pause();
      state = state.copyWith(state: MessageFileUploadState.paused);
      _logger.w('Upload paused for file: ${state.file?.path}');
    } else {
      _logger.w('No active upload task to pause.');
    }
  }

  void resume() {
    if (_uploadTask != null && state.state == MessageFileUploadState.paused) {
      _uploadTask?.resume();
      state = state.copyWith(state: MessageFileUploadState.uploading);
      _logger.i('Resumed upload for file: ${state.file?.path}');
    } else {
      _logger.w('No paused upload task to resume.');
    }
  }

  void cancel() {
    if (_uploadTask != null) {
      _uploadTask?.cancel();
      state = state.copyWith(
        state: MessageFileUploadState.canceled,
        progress: 0.0,
      );
      _logger.w('Upload canceled for file: ${state.file?.path}');
    } else {
      _logger.w('No active upload task to cancel.');
    }
  }
}

final messageFileUploadProvider = StateNotifierProvider.family<
    MessageFileUploadController, MessageFileUpload, String>(
  (ref, id) {
    final messageService = MessageService();
    return MessageFileUploadController(messageService);
  },
);
