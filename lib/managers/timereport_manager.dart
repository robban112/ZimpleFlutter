import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zimple/model/timereport.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:zimple/widgets/widgets.dart';

class TimereportManager {
  Map<String, List<TimeReport>> timereportMap = Map<String, List<TimeReport>>();
  Map<String, List<TimeReport>> timereportDateMap = Map<String, List<TimeReport>>();

  static TimereportManager of(BuildContext context) => context.read<ManagerProvider>().timereportManager;

  static TimereportManager watch(BuildContext context) => context.watch<ManagerProvider>().timereportManager;

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

  List<TimeReport> getLatestTimereports({int latestN = 12}) {
    return getAllTimereports().take(latestN).toList();
  }

  List<TimeReport> getAllTimereports() {
    List<TimeReport> timereports = [];
    timereportMap.forEach((key, value) {
      timereports += value;
    });
    return sortTimereportsByStartDate(timereports)!;
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

  List<TimeReport> getTimereportForMonth({required int year, required int month, List<String>? userIds}) {
    List<TimeReport> allTimereports = getAllTimereports();
    print("$year, $month");
    return allTimereports.where((timereport) => shouldIncludeTimereport(timereport, year, month, userIds)).toList();
  }

  bool shouldIncludeTimereport(TimeReport timereport, int year, int month, List<String>? userIds) {
    if (timereport.userId == null) return false;
    if (userIds == null) {
      return timereport.startDate.year == year && timereport.startDate.month == month;
    }
    return timereport.startDate.year == year && timereport.startDate.month == month && userIds.contains(timereport.userId);
  }
}
