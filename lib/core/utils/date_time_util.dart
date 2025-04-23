import 'package:intl/intl.dart';

/// Utility class for formatting and interpreting DateTime objects
class DateTimeUtil {
  /// Returns a human-readable label for a given [dateTime], like "Today", "Yesterday", or a formatted date
  static String day(DateTime dateTime) {
    final today = DateTime.now(); // Get the current date and time
    final difference =
        today.difference(dateTime).inDays; // Calculate the difference in days

    if (difference == 0) {
      return 'Today'; // If the date is today
    } else if (difference == 1) {
      return 'Yesterday'; // If the date was one day ago
    } else if (difference <= 7) {
      return DateFormat.EEEE()
          .format(dateTime); // Return the weekday name (e.g., Monday)
    } else {
      return DateFormat('d MMM yyyy')
          .format(dateTime); // Return the full date (e.g., 12 Apr 2025)
    }
  }
}
