import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'configs.dart';

Logger logger = Logger();
var appWidgets = AppWidgets();

extension StringCasingExtension on String {
  /// Capitalizes just the first letter of the string
  String capitalize() {
    return isNotEmpty
        ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}'
        : '';
  }

  /// Capitalizes the first letter of every word in the string
  String toTitleCase() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
}

class AppConstants {
  static const String appName = 'Great Clinic';

  static final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.([a-zA-Z]{2,})+",
  );

  static final RegExp phoneValidation = RegExp(r"^(?:\+88|88)?(01[3-9]\d{8})$");

  static final sessionExpireString = dotenv.env['SESSION_EXPIRE'] ?? '7 Days';

// Extract the number from the string
  final days = int.tryParse(sessionExpireString.split(' ').first) ?? 7;

  static DateTime get sessionExpire {
    final days = int.tryParse(sessionExpireString.split(' ').first) ?? 7;
    return DateTime.now()
        .add(Duration(days: days))
        .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  }

}

