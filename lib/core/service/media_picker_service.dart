import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';

class MediaPickerService {
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
}
