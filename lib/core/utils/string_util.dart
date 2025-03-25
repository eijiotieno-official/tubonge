
class StringUtil {
  static bool isUrl(String input) {
    final urlPattern =
        r'^(https?:\/\/)?([a-zA-Z0-9\-_]+\.[a-zA-Z]{2,})(\/\S*)?$';
    final urlRegex = RegExp(urlPattern);
    return urlRegex.hasMatch(input);
  }

  static bool isFilePath(String input) {
    // Checks for common file path structures for Unix-like systems and Windows
    final filePathPattern = r'^([a-zA-Z]:\\|\/)?([^\/\\:*?"<>|\r\n]+[\/\\]?)+$';
    final filePathRegex = RegExp(filePathPattern);
    return filePathRegex.hasMatch(input) && !isUrl(input);
  }
}
