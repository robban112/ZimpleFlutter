import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:zimple/managers/timereport_manager.dart';
import 'package:zimple/model/timereport.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/screens/TimeReporting/timereporting_details.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:collection/collection.dart';

class TimereportingListScreen extends StatefulWidget {
  @override
  _TimereportingListScreenState createState() =>
      _TimereportingListScreenState();
}

class _TimereportingListScreenState extends State<TimereportingListScreen> {
  Map<String, List<TimeReport>> groupTimereportsByMonth(
      List<TimeReport> timereports) {
    return groupBy(
        timereports, (TimeReport tr) => dateToYearMonth(tr.startDate));
  }

  Widget _buildMonthTimereports(Widget header, List<TimeReport> timereports) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: timereports.length,
            itemBuilder: (contex, index) {
              var timereport = timereports[index];
              return TimereportRow(
                timereport: timereport,
                didTapTimereport: (timereport) {
                  pushNewScreen(context,
                      screen: TimereportingDetails(
                        timereport: timereport,
                      ));
                },
              );
            }),
      ],
    );
  }

  Widget _buildHeader(String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Text(key,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
    );
  }

  @override
  Widget build(BuildContext context) {
    TimereportManager timereportManager =
        Provider.of<ManagerProvider>(context, listen: true).timereportManager;

    UserParameters user =
        Provider.of<ManagerProvider>(context, listen: true).user;
    var mappedTimereports =
        groupTimereportsByMonth(timereportManager.timereportMap[user.token]);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: Align(
              alignment: Alignment.centerLeft,
              child: Text("Mina tidrapporter",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0))),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: ListView.builder(
            itemCount: mappedTimereports.length,
            itemBuilder: (context, index) {
              String key = mappedTimereports.keys.elementAt(index);
              return _buildMonthTimereports(
                  _buildHeader(key), mappedTimereports[key]);
            }));
  }
}

class TimereportRow extends StatelessWidget {
  final TimeReport timereport;
  final Function(TimeReport) didTapTimereport;
  TimereportRow({this.timereport, this.didTapTimereport});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          didTapTimereport(timereport);
        },
        child: SizedBox(
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.12),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(-2, 2), // changes position of shadow
                    )
                  ]),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 16.0),
                child: Row(
                  children: [
                    Text(dayNumberInMonth(timereport.startDate),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(width: 6.0),
                    Text(dateStringMonth(timereport.startDate)),
                    Expanded(child: Container()),
                    Text(getHourDiff(timereport.startDate, timereport.endDate),
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                    SizedBox(width: 6.0),
                    Text("timmar")
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
