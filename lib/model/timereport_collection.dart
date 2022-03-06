import 'package:zimple/managers/customer_manager.dart';
import 'package:zimple/model/models.dart';

class TimeReportCollection {
  final List<TimeReport> timereports;

  TimeReportCollection({required this.timereports});

  int totalCustomers(CustomerManager customerManager) {
    List<String> customers = [];
    for (TimeReport timeReport in timereports) {
      if (timeReport.customerKey != null) customers.add(timeReport.customerKey!);
    }

    List<String> customerKeys =
        timereports.map((tr) => tr.customerKey).whereType<String>().where((element) => element != "").toList();

    for (var key in customerKeys) {
      print(customerManager.getCustomer(key)?.name);
    }
    return customerKeys.toSet().length;
  }

  double averageWorkingTime(int totalMinutes) {
    return totalMinutes / timereports.length;
  }

  int totalHours() {
    int hours = (totalminutes() / 60).floor();
    return hours;
  }

  int totalMinutesRemaining(int hours, int totalMinutes) {
    int remainingMinutes = totalMinutes - (hours * 60);
    return remainingMinutes;
  }

  int totalminutes() {
    return timereports.fold<int>(0, (prev, timereport) => prev + timereport.totalTime);
  }

  int totalBreak() {
    return timereports.fold<int>(0, (prev, timereport) => prev + timereport.breakTime);
  }

  double totalHoursWithoutBreak() {
    return totalHours() - (totalBreak() / 60);
  }
}
