import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zimple/extensions/double_extensions.dart';
import 'package:zimple/managers/timereport_manager.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/model/timereport_collection.dart';
import 'package:zimple/screens/TimeReporting/TimereportList/timereport_list_widget.dart';
import 'package:zimple/screens/TimeReporting/TimereportList/timereport_row_item.dart';
import 'package:zimple/screens/TimeReporting/timereporting_details.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/select_month_modal.dart';
import 'package:zimple/widgets/widgets.dart';

class SalaryBasisScreen extends StatefulWidget {
  const SalaryBasisScreen({Key? key}) : super(key: key);

  @override
  State<SalaryBasisScreen> createState() => _SalaryBasisScreenState();
}

class _SalaryBasisScreenState extends State<SalaryBasisScreen> {
  int month = thisMonth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        "Löneunderlag",
        trailing: _selectMonthButton(),
      ),
      body: BackgroundWidget(child: _body(context)),
    );
  }

  Widget _selectMonthButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: SelectMonthButton(
        onTap: onTapSelectMonth,
        selectedMonth: getMonthName(month),
      ),
    );
  }

  Widget _body(BuildContext context) {
    List<TimeReport> timereports = TimereportManager.watch(context).getTimereportForMonth(year: thisYear, month: month, userIds: [
      user(context).token,
    ]);
    TimeReportCollection collection = TimeReportCollection(timereports: timereports);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildOverview(context, collection),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              getTimereportsList(
                collection,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> getTimereportsList(TimeReportCollection collection) {
    return List.generate(
      collection.timereports.length,
      (index) => Column(
        children: [
          TimeReportRowItem(
            timereport: collection.timereports[index],
            onTapTimeReport: onTapTimeReport,
          ),
          TimeReportListSeparator(),
        ],
      ),
    );
  }

  Widget _buildOverview(BuildContext context, TimeReportCollection collection) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalHoursContainer(context, collection),
          const SizedBox(height: 24),
          Text("Tidrapporter", style: headerStyle),
          //const SizedBox(height: 12),
        ],
      ),
    );
  }

  Container _buildTotalHoursContainer(BuildContext context, TimeReportCollection collection) {
    return Container(
      height: 175,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: ThemeNotifier.of(context).borderColor),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: _buildHourText(
          collection.totalHoursWithoutBreak().parseToTwoDigits(),
        ),
      ),
    );
  }

  RichText _buildHourText(String amount) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: amount,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 32,
              color: ThemeNotifier.of(context).textColor,
            ),
          ),
          TextSpan(text: " "),
          TextSpan(
            text: "timmar",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ThemeNotifier.of(context).textColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void onTapTimeReport(TimeReport timereport) =>
      PersistentNavBarNavigator.pushNewScreen(context, screen: TimereportingDetails(timereport: timereport));

  void onTapSelectMonth() {
    showCupertinoDialog(
      context: context,
      builder: (context) => SelectMonthModal(
        onSelectMonth: onSelectMonth,
        selectedMonth: month,
      ),
    );
  }

  void onSelectMonth(int month) {
    setState(() => this.month = month);
  }
}

class SelectMonthButton extends StatelessWidget {
  final String selectedMonth;

  final VoidCallback onTap;

  const SelectMonthButton({
    Key? key,
    required this.onTap,
    required this.selectedMonth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: ThemeNotifier.darkCardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ThemeNotifier.of(context).borderColor),
        ),
        child: Row(
          children: [
            Icon(FeatherIcons.calendar, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(selectedMonth, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white))
          ],
        ),
      ),
    );
  }
}
