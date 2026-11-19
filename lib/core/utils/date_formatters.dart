import 'package:intl/intl.dart';

/// Formateadores de fecha/hora en español para recuerdos.
abstract final class DateFormatters {
  static final DateFormat fullDate = DateFormat("d 'de' MMMM 'de' y", 'es');
  static final DateFormat shortDate = DateFormat('d MMM y', 'es');
  static final DateFormat time = DateFormat('HH:mm', 'es');
  static final DateFormat monthYear = DateFormat('MMMM y', 'es');

  static String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  static String formatFullDate(DateTime date) => fullDate.format(date);

  static String formatShortDate(DateTime date) => shortDate.format(date);

  static String formatTime(DateTime date) => time.format(date);

  static String formatMonthYear(DateTime date) =>
      capitalize(monthYear.format(date));
}
