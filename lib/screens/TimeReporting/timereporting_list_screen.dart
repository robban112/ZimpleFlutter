import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:zimple/managers/event_manager.dart';
import 'package:zimple/managers/timereport_manager.dart';
import 'package:zimple/model/event.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/model/timereport.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/screens/TimeReporting/timereport_month_report_screen.dart';
import 'package:zimple/screens/TimeReporting/timereporting_details.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/weekday_to_string.dart';
import 'package:zimple/widgets/person_circle_avatar.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:collection/collection.dart';
import 'package:zimple/widgets/rectangular_button.dart';

class TimereportingListScreen extends StatefulWidget {
  final String? userId;
  TimereportingListScreen({this.userId});
  @override
  _TimereportingListScreenState createState() => _TimereportingListScreenState();
}

class _TimereportingListScreenState extends State<TimereportingListScreen> {
  var isSelectingMultiple = false;

  Map<String, List<TimeReport>>? mappedTimereports = Map<String, List<TimeReport>>();
  Map<TimeReport, bool> selectedTimereports = Map<TimeReport, bool>();
  Map<Person, bool> selectedPersons = Map<Person, bool>();
  late TimereportManager timereportManager;

  @override
  void initState() {
    super.initState();
  }

  Map<String, List<TimeReport>>? groupTimereportsByMonth(List<TimeReport>? timereports) {
    if (timereports == null) {
      return null;
    }
    return groupBy(timereports, (TimeReport tr) => dateToYearMonth(tr.startDate));
  }

  Widget _buildMonthTimereports(Widget header, List<TimeReport> timereports, EventManager eventManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: timereports.length,
            itemBuilder: (contex, index) {
              TimeReport timereport = timereports[index];
              Event? event = eventManager.getEventForKey(key: timereport.eventId ?? "");
              return TimereportRow(
                timereport: timereport,
                event: event,
                isSelected: selectedTimereports[timereport] ?? false,
                isSelectingMultiple: this.isSelectingMultiple,
                didTapTimereport: (timereport) {
                  isSelectingMultiple ? handleSelectTimereport(timereport) : goToTimereportingDetails(timereport);
                },
              );
            }),
      ],
    );
  }

  void handleSelectTimereport(TimeReport timereport) {
    if (!selectedTimereports.containsKey(timereport)) {
      selectedTimereports[timereport] = true;
    } else {
      selectedTimereports[timereport] = !selectedTimereports[timereport]!;
    }
    setState(() {});
  }

  void handleSelectPerson() {
    if (selectedPersons.entries == null) {
      return;
    }
    var timereportManager = Provider.of<ManagerProvider>(context, listen: false).timereportManager;
    List<String> personIds =
        selectedPersons.entries.where((element) => element.value).map((e) => e.key).map((e) => e.id).toList();
    print("personIds: $personIds");
    setState(() {
      mappedTimereports = groupTimereportsByMonth(timereportManager.getTimereportsForMulitple(personIds));
    });
  }

  void goToTimereportingDetails(TimeReport timereport) {
    pushNewScreen(context,
        screen: TimereportingDetails(
          timereport: timereport,
        ));
  }

  List<TimeReport> _getSelectedTimereports() {
    List<TimeReport> timereports = [];
    selectedTimereports.forEach((key, value) {
      if (value) {
        timereports.add(key);
      }
    });
    return timereports;
  }

  bool shouldShowShowTimereportsButton() {
    return _getSelectedTimereports().length > 1;
  }

  Widget _buildHeader(String key) {
    UserParameters user = Provider.of<ManagerProvider>(context, listen: true).user;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          user.isAdmin
              ? TextButton(
                  child: Text("Visa månadsrapport", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    pushNewScreen(context,
                        screen: TimereportMonthReportScreen(timereports: mappedTimereports![key]!, month: key));
                  },
                )
              : Container()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    EventManager eventManager = Provider.of<ManagerProvider>(context, listen: true).eventManager;
    timereportManager = Provider.of<ManagerProvider>(context, listen: true).timereportManager;

    if (widget.userId != null) {
      mappedTimereports = groupTimereportsByMonth(timereportManager.timereportMap[widget.userId]);
    }
    // var mappedTimereports =
    //     groupTimereportsByMonth(timereportManager.timereportMap[widget.userId]);

    return Scaffold(
      appBar: _buildAppBar(mappedTimereports, context),
      body: mappedTimereports != null
          ? Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                          widget.userId != null ? Container() : _buildPersonSelectComponent(),
                        ] +
                        List.generate(mappedTimereports!.length, (index) {
                          String key = mappedTimereports!.keys.elementAt(index);
                          return _buildMonthTimereports(_buildHeader(key), mappedTimereports![key]!, eventManager);
                        }) +
                        [SizedBox(height: 150)],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 300),
                    opacity: isSelectingMultiple ? 1 : 0,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: RectangularButton(
                        text: "Visa valda tidrapporter",
                        onTap: () {
                          pushNewScreen(context,
                              screen: TimereportingDetails(
                                listTimereports: _getSelectedTimereports(),
                              ));
                        },
                      ),
                    ),
                  ),
                )
              ],
            )
          : Center(child: Text("Inga tidrapporter hittade", style: TextStyle(fontSize: 20.0))),
    );
  }

  Widget _buildPersonSelectComponent() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Välj personer", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.0),
          _buildPersonChips(),
        ],
      ),
    );
  }

  Widget _buildPersonChips() {
    List<Person> persons = Provider.of<ManagerProvider>(context, listen: true).personManager.persons;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          children: List.generate(persons.length, (index) {
        var person = persons[index];
        var selected = selectedPersons[person] ?? false;
        return Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  print("selected person!");
                  if (!selectedPersons.containsKey(person)) {
                    selectedPersons[person] = true;
                  } else {
                    selectedPersons[person] = !selectedPersons[person]!;
                  }
                });
                handleSelectPerson();
              },
              child: Chip(
                elevation: 3,
                backgroundColor: selected ? green : Theme.of(context).cardColor,
                avatar: PersonCircleAvatar(
                  person: person,
                ),
                label: Text(person.name),
                //useDeleteButtonTooltip: true,
              ),
            ),
            SizedBox(width: 6.0)
          ],
        );
      })),
    );
  }

  AppBar _buildAppBar(Map<String, List<TimeReport>>? mappedTimereports, BuildContext context) {
    return AppBar(
      backgroundColor: primaryColor,
      elevation: 0,
      actions: <Widget>[
        TextButton(
          onPressed: () => {
            setState(() {
              this.isSelectingMultiple = !this.isSelectingMultiple;
            })
          },
          child: mappedTimereports != null
              ? Text(isSelectingMultiple ? "Välj en" : "Välj flera", style: TextStyle(fontSize: 17.0, color: Colors.white))
              : Container(),
        ),
      ],
      title: Align(
          alignment: Alignment.centerLeft,
          child: Text("", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18.0))),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class TimereportRow extends StatefulWidget {
  final TimeReport timereport;
  final Event? event;
  final Function(TimeReport) didTapTimereport;
  final bool isSelectingMultiple;
  final bool isSelected;
  TimereportRow(
      {required this.timereport,
      this.event,
      this.isSelectingMultiple = false,
      this.isSelected = false,
      required this.didTapTimereport});

  @override
  _TimereportRowState createState() => _TimereportRowState();
}

class _TimereportRowState extends State<TimereportRow> {
  Column _buildColumn({required Widget titleWidget, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        titleWidget,
        Text(subtitle, style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildCompletedRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 12.0),
        Row(
          children: [
            CircleAvatar(backgroundColor: green, radius: 10, child: Icon(Icons.check, size: 14, color: Colors.white)),
            SizedBox(
              width: 18.0,
            ),
            Text(
              "Färdig",
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Building Timereporting List Screen");
    var width = MediaQuery.of(context).size.width;
    const edgeInsets = EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
    return Padding(
      padding: edgeInsets,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                color: widget.timereport.isCompleted ? Theme.of(context).cardColor.withOpacity(0.5) : Theme.of(context).cardColor,
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(-2, 2), // changes position of shadow
                  )
                ]),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                splashColor: Colors.grey.shade300,
                onTap: () {
                  widget.didTapTimereport(widget.timereport);
                },
                child: SizedBox(
                    //height: 70,
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                  child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildColumn(
                              titleWidget: Text(dayNumberInMonth(widget.timereport.startDate),
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                              subtitle: dateToAbbreviatedString(widget.timereport.startDate)),
                          SizedBox(width: 16.0),
                          _buildColumn(
                              titleWidget: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: width / 2),
                                child: Text(widget.event?.title ?? "", maxLines: 1, style: TextStyle(fontSize: 17)),
                              ),
                              subtitle: widget.event?.customer ?? ""),
                          SizedBox(width: 6.0),
                          Expanded(child: Container()),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: widget.isSelectingMultiple ? 80 : 50,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Row(
                                children: [
                                  _buildColumn(
                                      titleWidget: Text(getHourDiff(widget.timereport.startDate, widget.timereport.endDate),
                                          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
                                      subtitle: "timmar"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      widget.timereport.isCompleted ? _buildCompletedRow() : Container()
                    ],
                  ),
                )),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 24.0, right: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedOpacity(
                opacity: widget.isSelectingMultiple ? 1 : 0,
                duration: Duration(milliseconds: 300),
                child: widget.isSelectingMultiple
                    ? (widget.isSelected
                        ? Icon(Icons.check_circle, color: green)
                        : Icon(Icons.radio_button_off_outlined, color: green))
                    : Container(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
