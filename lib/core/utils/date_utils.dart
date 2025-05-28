import 'package:intl/intl.dart';

class TubongeDateUtils {
  static String formatTime(DateTime dateTime, {bool use24HourFormat = false}) {
    final String timeFormat = use24HourFormat ? 'HH:mm' : 'h:mm a';
    return DateFormat(timeFormat).format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM d, y').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime,
      {bool use24HourFormat = false}) {
    return '${formatDate(dateTime)} ${formatTime(dateTime, use24HourFormat: use24HourFormat)}';
  }

  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }

  static String getRelativeTime(DateTime dateTime,
      {bool use24HourFormat = false}) {
    if (isToday(dateTime)) {
      return formatTime(dateTime, use24HourFormat: use24HourFormat);
    } else if (isYesterday(dateTime)) {
      return 'Yesterday';
    } else {
      return formatDate(dateTime);
    }
  }
}
