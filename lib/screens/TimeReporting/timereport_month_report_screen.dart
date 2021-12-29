import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:zimple/managers/customer_manager.dart';
import 'package:zimple/model/timereport.dart';
import 'package:zimple/screens/TimeReporting/Excel/excel_report.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:zimple/utils/weekday_to_string.dart';
import 'package:zimple/widgets/widgets.dart';
import 'package:share_plus/share_plus.dart';

class TimereportMonthReportScreen extends StatefulWidget {
  const TimereportMonthReportScreen({required this.timereports, required this.month, Key? key}) : super(key: key);

  final List<TimeReport> timereports;

  final String month;

  @override
  _TimereportMonthReportScreenState createState() => _TimereportMonthReportScreenState();
}

class _TimereportMonthReportScreenState extends State<TimereportMonthReportScreen> {
  int totalHours(int totalMinutes) {
    int hours = (totalMinutes / 60).floor();
    return hours;
  }

  int totalMinutesRemaining(int hours, int totalMinutes) {
    int remainingMinutes = totalMinutes - (hours * 60);
    return remainingMinutes;
  }

  int totalminutes() {
    return widget.timereports.fold<int>(0, (prev, timereport) => prev + timereport.totalTime);
  }

  int totalBreak() {
    return widget.timereports.fold<int>(0, (prev, timereport) => prev + timereport.breakTime);
  }

  int totalCustomers() {
    List<String> customers = [];
    for (TimeReport timeReport in widget.timereports) {
      if (timeReport.customerKey != null) customers.add(timeReport.customerKey!);
    }

    List<String> customerKeys =
        widget.timereports.map((tr) => tr.customerKey).whereType<String>().where((element) => element != "").toList();

    print(customerKeys.toSet());

    CustomerManager customerManager = ManagerProvider.of(context).customerManager;

    for (var key in customerKeys) {
      print(customerManager.getCustomer(key)?.name);
    }
    return customerKeys.toSet().length;
  }

  double averageWorkingTime(int totalMinutes) {
    return totalMinutes / widget.timereports.length;
  }

  Padding _buildRow(String left, String right, {String? appendRight}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.normal)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(right, style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              appendRight != null ? Text(appendRight) : Container()
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRowWidget(String title, Widget widget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.normal)),
          widget,
        ],
      ),
    );
  }

  Widget _buildHoursMinutesWidget(int totalMinutes) {
    int hours = totalHours(totalMinutes);
    int minutes = totalMinutesRemaining(hours, totalMinutes);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (hours > 0) Text(hours.toString(), style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
        if (hours > 0) const SizedBox(width: 2),
        if (hours > 0) Text("h", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal)),
        if (hours > 0) const SizedBox(width: 8),
        if (minutes > 0) Text(minutes.toString(), style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
        if (minutes > 0) const SizedBox(width: 2),
        if (minutes > 0) Text("min", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int _totalBreakMinutes = totalBreak();
    int _totalMinutes = totalminutes();
    int _totalMinutesAfterBreak = _totalMinutes - _totalBreakMinutes;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: primaryColor,
        title: Text(
          "Månadsrapport ${widget.month}",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TimereportChartView(timereports: widget.timereports),
              const SizedBox(height: 24),
              _title("Statistik"),
              _buildRowWidget("Totaltid: ", _buildHoursMinutesWidget(_totalMinutes)),
              _buildRowWidget("Total arbetad tid", _buildHoursMinutesWidget(_totalMinutesAfterBreak)),
              _buildRowWidget("Total rast: ", _buildHoursMinutesWidget(_totalBreakMinutes)),
              _buildRowWidget("Snitt arbetstid: ", _buildHoursMinutesWidget((_totalMinutes ~/ widget.timereports.length))),
              _buildRowWidget("Snitt rast: ", _buildHoursMinutesWidget((_totalBreakMinutes ~/ widget.timereports.length))),
              _buildRow("Antal rapporter: ", widget.timereports.length.toString(), appendRight: 'st'),
              //_buildRow("Antal kunder: ", totalCustomers().toString(), appendRight: 'st'),
              const SizedBox(height: 24),
              _title("Funktioner"),
              _buildExcelCreator()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExcelCreator() {
    return ListedView(
      rowInset: const EdgeInsets.symmetric(vertical: 12),
      items: [
        ListedItem(
          leadingIcon: FontAwesome5.file_export,
          text: 'Generera excel från rapport',
          onTap: () => _onTapGenerateExcel(context),
        ),
      ],
    );
  }

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 0.0,
        ),
        child: Text(text, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
      );

  void _onTapGenerateExcel(BuildContext context) async {
    ExcelManager excelManager = ExcelManager(
      month: widget.month,
      timereports: widget.timereports,
      personManager: ManagerProvider.of(context).personManager,
      eventManager: ManagerProvider.of(context).eventManager,
      customerManager: ManagerProvider.of(context).customerManager,
    );
    try {
      String filePath = await excelManager.saveExcel();
      print("file saved at: $filePath");
      Share.shareFiles([filePath]);
    } catch (error) {
      // Show Error
      _showSnackbarError();
    }
  }

  void _showSnackbarError() {
    final snackBar = SnackBar(
      content: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text('Det blev tyvärr något fel. Försök igen eller kontakta support'),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class TimereportChartView extends StatelessWidget {
  final List<TimeReport> timereports;

  const TimereportChartView({
    Key? key,
    required this.timereports,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (timereports.length <= 0) return Container();
    List<DateTime> dates = _getAllDatesInMonth(timereports.first.startDate);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("Tidrapporter", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              height: 156,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: List.generate(
                    dates.length,
                    (index) {
                      return Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildTimeContainer(context, _getTotalTimeForDate(dates[index])),
                            const SizedBox(height: 8),
                            _buildDateLegend(dates[index]),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateLegend(DateTime date) {
    return Column(
      children: [
        Text(monthDayString(date), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Text(dateToAbbreviatedString(date), style: TextStyle(fontSize: 11.0, color: null)),
      ],
    );
  }

  Widget _buildTimeContainer(BuildContext context, int totalTime) {
    if (totalTime == 0) return Container();
    double totalHours = totalTime / 60;
    double diff = totalHours / 12;
    if (diff > 1) diff = 1;
    return Column(
      children: [
        Text("${(totalTime / 60).toStringAsFixed(0)}h", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          height: 75 * diff,
          width: 25,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  TimeReport? _getTimereportForDate(DateTime date) {
    try {
      return timereports.firstWhere((timereport) => timereport.startDate.isSameDate(date));
    } catch (error) {
      return null;
    }
  }

  int _getTotalTimeForDate(DateTime date) {
    List<TimeReport> dateTimereports = timereports.where((timereport) => timereport.startDate.isSameDate(date)).toList();
    return dateTimereports.fold<int>(0, (prev, timereport) => prev + timereport.totalTime);
  }

  List<DateTime> _getAllDatesInMonth(DateTime date) {
    DateTime dateAggr = DateTime(date.year, date.month, 1);
    List<DateTime> dates = [dateAggr];
    int i = 2;

    while (dateAggr.month == date.month) {
      dateAggr = DateTime(date.year, date.month, i);
      if (dateAggr.month == date.month) dates.add(dateAggr);
      i++;
    }
    return dates;
  }
}
