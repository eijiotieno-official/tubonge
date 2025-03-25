import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/string_util.dart';
import '../models/message_model.dart';
import 'time_status_view.dart';


class ImageMessageView extends ConsumerWidget {
  final ImageMessage message;
  final bool showStatus;
  const ImageMessageView({
    super.key,
    required this.message,
    required this.showStatus,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    File file = File(message.imageUri);

    bool fileExists =
        file.existsSync() && StringUtil.isFilePath(message.imageUri);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // if (fileExists) UploadProgressView(message: message),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ImageFullView(uri: message.imageUri);
                },
              ),
            );
          },
          child: Hero(
            tag: message.imageUri,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: fileExists == false
                  ? CachedNetworkImage(
                      imageUrl: message.imageUri,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      file,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),
        if (message.text != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(message.text!),
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TimeStatus(
            timeSent: message.timeSent,
            status: message.status,
            showStatus: showStatus,
          ),
        ),
      ],
    );
  }
}

class ImageFullView extends StatelessWidget {
  final String uri;
  const ImageFullView({super.key, required this.uri});

  @override
  Widget build(BuildContext context) {
    File file = File(uri);

    bool fileExists = file.existsSync() && StringUtil.isFilePath(uri);

    return Hero(
      tag: uri,
      child: Center(
        child: fileExists == false
            ? CachedNetworkImage(
                imageUrl: uri,
                fit: BoxFit.cover,
              )
            : Image.file(
                file,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
