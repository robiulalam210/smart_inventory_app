import 'package:intl/intl.dart';
class AppWidgets {
  String formatStringDDMMYY(dynamic date) {
    if (date == null) return 'N/A';
    final parsedDate = DateTime.tryParse(date.toString());
    return parsedDate != null
        ? DateFormat('dd/MM/yyyy').format(parsedDate)
        : 'N/A';
  }
  //!convertDateTime
  String convertDateTime(DateTime? dateTime, String format) {
    /*
    format[
      'yyyy-MM-dd'
      'EEEE, MMM d, yyyy'
      'MM-dd-yyyy HH:mm'
      'MMM d, h:mm a'
      'E, d MMM yyyy HH:mm:ss'
    ]
    */
    if (dateTime == null) {
      return '';
    }
    final dateFormatter = DateFormat(format);
    return dateFormatter.format(dateTime.toLocal());
  }

  //!convertDateTime
  String convertDateTimeDDMMMYYYY(
    DateTime? dateTime,
  ) {
    /*
    format[
      'yyyy-MM-dd'
      'EEEE, MMM d, yyyy'
      'MM-dd-yyyy HH:mm'
      'MMM d, h:mm a'
      'E, d MMM yyyy HH:mm:ss'
    ]
    */
    if (dateTime == null) {
      return '';
    }
    final dateFormatter = DateFormat("dd MMM yyyy");
    return dateFormatter.format(dateTime.toLocal());
  } //!convertDateTime

  String convertDateTimeDDMMYYYY(
    DateTime? dateTime,
  ) {
    /*
    format[
      'yyyy-MM-dd'
      'EEEE, MMM d, yyyy'
      'MM-dd-yyyy HH:mm'
      'MMM d, h:mm a'
      'E, d MMM yyyy HH:mm:ss'
    ]
    */
    if (dateTime == null) {
      return '';
    }
    final dateFormatter = DateFormat("dd-MM-yyyy");
    return dateFormatter.format(dateTime.toLocal());
  }  String convertDateTimeDDMMYYYYHHMMA(
    DateTime? dateTime,
  ) {
    /*
    format[
      'yyyy-MM-dd'
      'EEEE, MMM d, yyyy'
      'MM-dd-yyyy HH:mm'
      'MMM d, h:mm a'
      'E, d MMM yyyy HH:mm:ss'
    ]
    */
    if (dateTime == null) {
      return '';
    }
    final dateFormatter = DateFormat("dd-MM-yyyy hh:mm:a");
    return dateFormatter.format(dateTime.toLocal());
  }

  String convertDateTimeYYYYMMDD(
    DateTime? dateTime,
  ) {
    /*
    format[
      'yyyy-MM-dd'
      'EEEE, MMM d, yyyy'
      'MM-dd-yyyy HH:mm'
      'MMM d, h:mm a'
      'E, d MMM yyyy HH:mm:ss'
    ]
    */
    if (dateTime == null) {
      return '';
    }
    final dateFormatter = DateFormat("yyyy-MM-dd");
    return dateFormatter.format(dateTime.toLocal());
  }


}
