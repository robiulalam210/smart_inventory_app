import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';


String formatTime(String? time) {
  if (time == null || time.isEmpty) return "";

  try {
    // Try parsing as 24-hour format first (HH:mm:ss)
    final parsed = DateFormat("HH:mm:ss").parse(time);
    return DateFormat("hh:mm a").format(parsed);
  } catch (_) {
    try {
      // Fallback: parse as 12-hour format (h:mm a)
      final parsed = DateFormat("h:mm a").parse(time);
      return DateFormat("hh:mm a").format(parsed);
    } catch (_) {
      // If parsing fails, return original
      return time;
    }
  }
}
String? formatDateTime({dynamic dateTime, String? format}) {
  if (dateTime == null) {
    return null;
  }

  try {
    final dateFormatter = DateFormat(format ?? 'dd MMM yyyy');
    if (dateTime is DateTime) {
      return dateFormatter.format(dateTime.toLocal());
    }

    final DateTime parsedDate = DateTime.parse(dateTime);
    return dateFormatter.format(parsedDate);
  } catch (e) {
    if (kDebugMode) {
      print("object convertDateTime e: $e");
    }
    return null;
  }
}
// Add this helper function
DateTime? parseCustomDate(dynamic dateValue) {
  if (dateValue == null || dateValue is! String) {
    return null;
  }

  final dateString = dateValue.trim();

  if (dateString.isEmpty || dateString.toLowerCase() == 'null') {
    return null;
  }

  try {
    // ISO format yyyy-MM-dd
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateString)) {
      return DateTime.parse(dateString);
    }

    // Custom format like "Wed Mar 12 2025 00:00:00 GMT+0600"
    final parts = dateString.split(' ');
    if (parts.length >= 5) {
      final month = _monthToNumber(parts[1]);
      final day = parts[2].padLeft(2, '0');
      final year = parts[3];
      final isoString = '$year-$month-$day';
      return DateTime.parse(isoString);
    }

    // New: dd/MM/yyyy format, e.g. "03/07/2004"
    if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(dateString)) {
      final parts = dateString.split('/');
      final day = parts[0].padLeft(2, '0');
      final month = parts[1].padLeft(2, '0');
      final year = parts[2];
      final isoString = '$year-$month-$day'; // Convert to yyyy-MM-dd
      return DateTime.parse(isoString);
    }

    // NEW: dd-MM-yyyy format, e.g. "16-07-2025"
    if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(dateString)) {
      final parts = dateString.split('-');
      final day = parts[0].padLeft(2, '0');
      final month = parts[1].padLeft(2, '0');
      final year = parts[2];
      final isoString = '$year-$month-$day'; // Convert to yyyy-MM-dd
      return DateTime.parse(isoString);
    }

    // Last resort: try direct parse (might fail)
    return DateTime.parse(dateString);
  } catch (e, stack) {
    debugPrint('Error parsing date "$dateString": $e\n$stack');
    return null;
  }
}


int _monthToNumber(String month) {
  const months = {
    'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
    'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
    'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
  };
  return int.parse(months[month] ?? '01');
}


DateTime? parseDate(dynamic value) {
  if (value == null) return null;

  if (value is DateTime) return value;
  if (value is int) {
    // Assume it's a UNIX timestamp (seconds)
    return DateTime.fromMillisecondsSinceEpoch(value * 1000);
  }
  final stringVal = value.toString();
  final parsed = DateTime.tryParse(stringVal);
  if (parsed != null) return parsed;
  return null;
}

String monthToNumber(String month) {
  const months = {
    'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04', 'May': '05', 'Jun': '06',
    'Jul': '07', 'Aug': '08', 'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
  };
  return months[month] ?? '01';
}
DateTime? tryParseDob(String dobString) {
  // First try to parse the complex format with timezone
  final complexFormat = RegExp(
      r'^(?<weekday>\w{3})\s(?<month>\w{3})\s(?<day>\d{2})\s(?<year>\d{4})\s'
      r'(?<time>\d{2}:\d{2}:\d{2})\sGMT(?<tz>[+-]\d{4})\s\(.+\)$');

  if (complexFormat.hasMatch(dobString)) {
    final match = complexFormat.firstMatch(dobString);
    try {
      // Reconstruct a simpler date string without timezone name
      final dateStr =
          '${match!.namedGroup('month')} ${match.namedGroup('day')} '
          '${match.namedGroup('year')} ${match.namedGroup('time')} '
          '${match.namedGroup('tz')}';

      return DateFormat('MMM dd yyyy HH:mm:ss Z').parse(dateStr);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Try standard formats
  final formats = [
    DateFormat('dd/MM/yyyy'),
    DateFormat('dd-MM-yyyy'),
    DateFormat('yyyy-MM-dd'),
    DateFormat('MMM dd yyyy'), // For "Jul 03 2004" format
  ];

  for (var format in formats) {
    try {
      return format.parseStrict(dobString);
    } catch (_) {}
  }

  // Try parsing as ISO string
  try {
    return DateTime.parse(dobString);
  } catch (e) {
    return null;
  }
}

String calculateAgeDB(String? dobString) {
  // Debug print the input

  if (dobString == null ||
      dobString.toLowerCase() == 'null' ||
      dobString.isEmpty) {
    debugPrint('Invalid DOB - returning Unknown');
    return 'Unknown';
  }

  try {
    final dob = DateTime.parse(dobString);
    final now = DateTime.now();



    int age = now.year - dob.year;

    // Debug before adjustment

    // Adjust age if birthday hasn't occurred yet this year
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }

    // Final check
    if (age < 0) {
      debugPrint('Negative age calculated - returning Unknown');
      return 'Unknown';
    }

    return age.toString();
  } catch (e) {
    debugPrint('Error parsing date "$dobString": $e');
    return 'Unknown';
  }
}
