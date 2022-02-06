class WeekPageController {
  late void Function(int prevNumberOfDays, int newNumberOfDays, DateTime? zoomDate) daysChanged;
  late void Function(DateTime zoomDate) zoomDate;
}
