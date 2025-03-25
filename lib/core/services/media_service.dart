import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

enum MimeType {
  any,
  media,
  image,
  video,
  audio,
  document,
}

class MediaService {
  Future<Either<String, List<PlatformFile>>> openPicker({
    int maxCount = 1,
    required FileType type,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: maxCount > 1,
        type: type,
      );

      if (result != null && result.files.isNotEmpty) {
        final files = result.files;

        return Right(files);
      }

      return Right([]);
    } catch (e) {
      return Left(e.toString());
    }
  }

  MimeType getType(PlatformFile file) {
    // Get the file name
    final String fileName = file.name;

    // If the file name is empty, return `MimeType.any`
    if (fileName.isEmpty) {
      return MimeType.any;
    }

    // Use the `mime` package to get the MIME type from the file name
    final String? mimeType = lookupMimeType(fileName);

    // If the MIME type is null, return `MimeType.any`
    if (mimeType == null) {
      return MimeType.any;
    }

    // Map the MIME type to the appropriate `MimeType` enum
    if (mimeType.startsWith('image/')) {
      return MimeType.image;
    } else if (mimeType.startsWith('video/')) {
      return MimeType.video;
    } else if (mimeType.startsWith('audio/')) {
      return MimeType.audio;
    } else if (mimeType.startsWith('application/') ||
        mimeType.startsWith('text/')) {
      return MimeType.document;
    } else {
      return MimeType.any;
    }
  }
}
