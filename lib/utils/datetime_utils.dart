import 'package:intl/intl.dart';

// Formats a DateTime into a human-readable string
String formatDateTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays > 365) {
    return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
  } else if (difference.inDays > 30) {
    return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
  } else {
    return 'Just now';
  }
}

// Formats a DateTime into full date and time
String formatFullDateTime(DateTime dateTime) {
  return DateFormat('MMM d, yyyy \'at\' h:mm a').format(dateTime);
}

// Formats a DateTime into just a date
String formatDate(DateTime dateTime) {
  return DateFormat('MMM d, yyyy').format(dateTime);
}

// Formats a DateTime into just a time
String formatTime(DateTime dateTime) {
  return DateFormat('h:mm a').format(dateTime);
}
