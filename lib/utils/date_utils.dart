import 'package:intl/intl.dart';
import 'package:zimple/utils/constants.dart';

int weekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  return ((dayOfYear - date.weekday + 10) / 7).floor();
}

bool isSameWeek(DateTime date1, DateTime date2) {
  return weekNumber(date1) == weekNumber(date2);
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return this.year == other.year && this.month == other.month && this.day == other.day;
  }
}

bool isCurrentWeek(DateTime date) {
  var now = DateTime.now();
  var _weekNumber = weekNumber(date);
  var nowWeekNumber = weekNumber(now);
  return now.year == date.year && now.month == date.month && _weekNumber == nowWeekNumber;
}

bool isFirstDayOfMonth(DateTime date) {
  return date.day == 1;
}

String dayNumberInMonth(DateTime date) {
  DateFormat formattedDate = DateFormat(DateFormat.DAY, locale);
  return formattedDate.format(date);
}

String yearString(DateTime date) {
  DateFormat formatter = DateFormat('yyyy');
  return formatter.format(date);
}

String dateString(DateTime date) {
  DateFormat formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(date);
}

String monthDayString(DateTime date) {
  DateFormat formatter = DateFormat('MM-dd');
  return formatter.format(date);
}

String dateStringVerbose(DateTime date) {
  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm', locale);
  return formatter.format(date);
}

String dateStringMonthHourMinute(DateTime date) {
  DateFormat formatter = DateFormat('dd MMMM HH:mm', locale);
  return formatter.format(date);
}

String dateStringMonth(DateTime date) {
  DateFormat formatter = DateFormat('MMMM');
  return formatter.format(date);
}

bool isToday(DateTime date) {
  DateTime now = DateTime.now();
  return (now.year == date.year && now.month == date.month && now.day == date.day);
}

String dateToHourMinute(DateTime date) {
  return DateFormat('HH:mm', locale).format(date);
}

String dateToYearMonthDay(DateTime date) {
  return DateFormat('yyyy-MM-dd', locale).format(date);
}

String dateToYearMonth(DateTime date) {
  return DateFormat('yyyy MMMM', locale).format(date);
}

DateTime firstDayOfWeek(DateTime date) {
  return date.subtract(Duration(days: date.weekday - 1));
}

List<DateTime> getDateRange(DateTime startDate, int daysForward) {
  List<DateTime> dates = [];
  for (var i = 0; i < daysForward; i++) {
    dates.add(startDate.add(Duration(days: i)));
  }
  return dates;
}

String getHourDiff(DateTime startDate, DateTime endDate, {int minutesBreak = 0}) {
  int minutes = endDate.difference(startDate).inMinutes;
  minutes -= minutesBreak;
  String minutesToHours = (minutes / 60).toStringAsFixed(2);
  if (minutesToHours.endsWith("00")) return (minutes / 60).round().toString();
  return minutesToHours;
}

String getHourDiffPresentable(DateTime startDate, DateTime endDate, {int minutesBreak = 0}) {
  int minutes = endDate.difference(startDate).inMinutes;
  minutes -= minutesBreak;
  String minutesToHours = (minutes / 60).toStringAsFixed(2);
  if (minutesToHours.endsWith("00")) return (minutes / 60).round().toString();
  return minutesToHours;
}

List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
  List<DateTime> days = [];
  for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
    days.add(startDate.add(Duration(days: i)));
  }
  return days;
}
