String weekdayToString(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return "Monday";
    case DateTime.tuesday:
      return "Tuesday";
    case DateTime.wednesday:
      return "Wednesday";
    case DateTime.thursday:
      return "Thursday";
    case DateTime.friday:
      return "Friday";
    case DateTime.saturday:
      return "Saturday";
    case DateTime.sunday:
      return "Sunday";
    default:
      return "Error";
  }
}

String dateToAbbreviatedString(DateTime date) {
  var weekday = date.weekday;
  switch (weekday) {
    case DateTime.monday:
      return "Mån";
    case DateTime.tuesday:
      return "Tis";
    case DateTime.wednesday:
      return "Ons";
    case DateTime.thursday:
      return "Tor";
    case DateTime.friday:
      return "Fre";
    case DateTime.saturday:
      return "Lör";
    case DateTime.sunday:
      return "Sön";
    default:
      return "Err";
  }
}
