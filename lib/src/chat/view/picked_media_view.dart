import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/provider/media_picker_provider.dart';


class PickedMediaView extends ConsumerWidget {
  const PickedMediaView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final  pickedMedias =
        ref.watch(filePickerProvider).value ?? [];

    return pickedMedias.isNotEmpty
        ? SizedBox(
            width: double.infinity,
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: pickedMedias.length,
              itemBuilder: (context, index) {
                final PlatformFile file = pickedMedias[index];

                return _buildImageView(file);
              },
            ),
          )
        : SizedBox.shrink();
  }

  Widget _buildImageView(PlatformFile file) => Image.file(
        File(file.path!),
        width: 100,
        fit: BoxFit.cover,
      );
}
