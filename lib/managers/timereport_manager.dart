import 'package:zimple/model/timereport.dart';
import 'package:zimple/utils/date_utils.dart';

class TimereportManager {
  Map<String, List<TimeReport>> timereportMap = Map<String, List<TimeReport>>();
  Map<String, List<TimeReport>> timereportDateMap = Map<String, List<TimeReport>>();

  void addTimereport({required String userId, required TimeReport timeReport}) {
    if (!timereportMap.containsKey(userId)) {
      timereportMap[userId] = [timeReport];
    } else {
      timereportMap[userId]!.add(timeReport);
    }
  }

  List<TimeReport> getTimereports(String userId) {
    return sortTimereportsByStartDate(timereportMap[userId]) ?? [];
  }

  List<TimeReport> getTimereportsForMulitple(List<String> userIds) {
    List<TimeReport> timereports = [];
    userIds.forEach((id) {
      var userTimereports = timereportMap[id];
      if (userTimereports != null) {
        timereports.addAll(userTimereports);
      }
    });
    return sortTimereportsByStartDate(timereports) ?? [];
  }

  TimeReport? getTimereport(String timereportId, String userId) {
    List<TimeReport>? userTimereports = timereportMap[userId];
    if (userTimereports == null) return null;

    return userTimereports.firstWhere((timereport) => timereport.id == timereportId, orElse: null);
  }

  //List<TimeReport> getTimeReportsByMonth(DateTime date) {}

  List<TimeReport>? sortTimereportsByStartDate(List<TimeReport>? timereports) {
    if (timereports == null) {
      return null;
    }
    timereports.sort((a, b) => b.startDate.compareTo(a.startDate));
    return timereports;
  }

  void sortTimereportsByMonth(List<TimeReport> timereports) {
    timereports.forEach((timereport) {
      var key = dateToYearMonth(timereport.startDate);
      if (timereportMap.containsKey(key)) {
        timereportMap[key]!.add(timereport);
      } else {
        timereportMap[key] = [timereport];
      }
    });
  }
}
