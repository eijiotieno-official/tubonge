import 'package:intl/intl.dart';

class DateTimeUtil {
  static String day(DateTime dateTime) {
    final today = DateTime.now();
    final difference = today.difference(dateTime).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference <= 7) {
      return DateFormat.EEEE().format(dateTime);
    } else {
      return DateFormat('d MMM yyyy').format(dateTime);
    }
  }
}
