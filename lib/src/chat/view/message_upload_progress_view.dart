import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/message_file_upload_controller.dart';
import '../models/message_model.dart';

class MessageUploadProgressView extends ConsumerWidget {
  final Message message;
  const MessageUploadProgressView({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MessageFileUpload uploadState =
        ref.watch(messageFileUploadProvider(message.id));

    final uploadNotifier =
        ref.read(messageFileUploadProvider(message.id).notifier);

    IconData icon = Icons.upload_rounded;

    switch (uploadState.state) {
      case MessageFileUploadState.uploading:
        icon = Icons.pause_rounded;
        break;
      default:
        icon = Icons.upload_rounded;
    }

    return Row(
      children: [
        Flexible(
          child: LinearProgressIndicator(
            minHeight: 5,
            value: uploadState.progress,
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: IconButton.filledTonal(
            padding: EdgeInsets.zero,
            onPressed: () {
              if (uploadState.state == MessageFileUploadState.paused) {
                uploadNotifier.resume();
              } else if (uploadState.state ==
                  MessageFileUploadState.uploading) {
                uploadNotifier.pause();
              } else {
                uploadNotifier.upload(message);
              }
            },
            icon: Icon(icon),
          ),
        ),
      ],
    );
  }
}
