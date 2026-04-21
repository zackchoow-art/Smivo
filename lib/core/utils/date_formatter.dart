import 'package:timeago/timeago.dart' as timeago;

/// Date and time formatting helpers.
///
/// Wraps the timeago package and standard DateTime formatting
/// to provide consistent date display throughout the app.
class DateFormatter {
  DateFormatter._();

  /// Returns a human-readable relative time string (e.g. "3 hours ago").
  static String relative(DateTime dateTime) =>
      timeago.format(dateTime);

  /// Returns a short date string (e.g. "Apr 18, 2026").
  static String shortDate(DateTime dateTime) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dateTime.month - 1]} '
        '${dateTime.day}, '
        '${dateTime.year}';
  }

  /// Returns date in YYYY-MM-DD format for API calls.
  static String isoDate(DateTime dateTime) =>
      '${dateTime.year}-'
      '${dateTime.month.toString().padLeft(2, '0')}-'
      '${dateTime.day.toString().padLeft(2, '0')}';
}
