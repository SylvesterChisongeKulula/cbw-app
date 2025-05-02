// lib/utils/date_formatter.dart
import 'package:intl/intl.dart';

class DateFormatter {
  static String getFormattedTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
  
  static String getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else if (dateToCheck.isAfter(today.subtract(Duration(days: 7)))) {
      return DateFormat('EEEE').format(date); // Day name
    } else {
      return DateFormat('MMM d').format(date); // Month and day
    }
  }
  
  static String getMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(time.year, time.month, time.day);
    
    if (dateToCheck == today) {
      return DateFormat('HH:mm').format(time);
    } else {
      return '${DateFormat('MMM d').format(time)}, ${DateFormat('HH:mm').format(time)}';
    }
  }
  
  static String formatLastActive(DateTime? time) {
    if (time == null) return 'Offline';
    
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}

