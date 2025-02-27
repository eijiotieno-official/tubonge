import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/provider/media_picker_provider.dart';

class PickedMediaView extends ConsumerWidget {
  const PickedMediaView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pickedMedias = ref.watch(filePickerProvider).value ?? [];

    return pickedMedias.isNotEmpty
        ? SizedBox(
            width: double.infinity,
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: pickedMedias.length,
              itemBuilder: (context, index) {
                final PlatformFile file = pickedMedias[index];

                return _buildImageView(
                  bytes: file.bytes,
                  onRemove: () {
                    ref.read(filePickerProvider.notifier).remove(file);
                  },
                );
              },
            ),
          )
        : SizedBox.shrink();
  }

  Widget _buildImageView({
    required Uint8List? bytes,
    required Function() onRemove,
  }) =>
      bytes == null
          ? SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SizedBox(
                width: 150,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.memory(
                          bytes,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: IconButton.filledTonal(
                            onPressed: onRemove,
                            icon: Icon(Icons.close_rounded),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
}
