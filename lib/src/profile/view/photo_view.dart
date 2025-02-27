import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class PhotoView extends StatelessWidget {
  final VoidCallback onPickImage;
  final PlatformFile? platformFile;
  final String? photoUrl;

  const PhotoView({
    super.key,
    required this.onPickImage,
    this.platformFile,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).hoverColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: onPickImage,
        child: SizedBox(
          height: screenWidth * 0.25,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: _buildImage(screenWidth),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(double screenWidth) {
    if (platformFile != null && platformFile!.bytes != null) {
      return Image.memory(
        platformFile!.bytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholder(screenWidth),
      );
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: photoUrl!,
        fit: BoxFit.cover,
        errorWidget: (context, error, stackTrace) =>
            _buildPlaceholder(screenWidth),
      );
    } else {
      return _buildPlaceholder(screenWidth);
    }
  }

  Widget _buildPlaceholder(double screenWidth) {
    return Center(
      child: Icon(
        Icons.camera_alt_rounded,
        size: screenWidth * 0.1,
      ),
    );
  }
}
