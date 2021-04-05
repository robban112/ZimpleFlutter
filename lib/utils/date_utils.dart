import 'package:intl/intl.dart';

int weekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  return ((dayOfYear - date.weekday + 10) / 7).floor();
}

bool isSameWeek(DateTime date1, DateTime date2) {
  return weekNumber(date1) == weekNumber(date2);
}

bool isFirstDayOfMonth(DateTime date) {
  return date.day == 1;
}

String yearString(DateTime date) {
  DateFormat formatter = DateFormat('yyyy');
  return formatter.format(date);
}

String dateString(DateTime date) {
  DateFormat formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(date);
}

String dateStringVerbose(DateTime date) {
  DateFormat formatter = DateFormat('yyyy-MM-dd kk:mm');
  return formatter.format(date);
}

String dateStringMonth(DateTime date) {
  DateFormat formatter = DateFormat('MMMM');
  return formatter.format(date);
}

bool isToday(DateTime date) {
  DateTime now = DateTime.now();
  return (now.year == date.year &&
      now.month == date.month &&
      now.day == date.day);
}

String dateToHourMinute(DateTime date) {
  return DateFormat('kk:mm').format(date);
}

String dateToYearMonthDay(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

DateTime firstDayOfWeek(DateTime date) {
  return date.subtract(Duration(days: date.weekday - 1));
}
