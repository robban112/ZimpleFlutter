import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:zimple/managers/event_manager.dart';
import 'package:zimple/model/event.dart';
import 'package:zimple/model/timereport.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/network/firebase_timereport_manager.dart';
import 'package:zimple/screens/Calendar/event_detail_screen.dart';
import 'package:zimple/screens/TimeReporting/Invoice/generate_invoice_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:zimple/widgets/conditional_widget.dart';
import 'package:zimple/widgets/future_image_widget.dart';
import 'package:zimple/widgets/page_dots_indicator.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:zimple/extensions/string_extensions.dart';

class TimereportingDetails extends StatefulWidget {
  final TimeReport? timereport;
  final List<TimeReport>? listTimereports;
  final bool isViewingSingle;
  TimereportingDetails({this.timereport, this.listTimereports}) : isViewingSingle = timereport != null;

  @override
  _TimereportingDetailsState createState() => _TimereportingDetailsState();
}

class _TimereportingDetailsState extends State<TimereportingDetails> {
  final _key = GlobalKey();
  final List<String> actionsSingleTimereport = ["Markera färdig", "Ta bort"];
  final List<String> actionsMultipleTimereport = ["Markera färdiga", "Ta bort alla", "Skapa faktura"];

  AppBar _buildAppbar(BuildContext context, UserParameters user) {
    return AppBar(
        backgroundColor: primaryColor,
        elevation: 0.0,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Tidrapport detaljer",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: user.isAdmin ? _buildActions(context) : []);
  }

  @override
  Widget build(BuildContext context) {
    print("Building Timereporting Details Screen");
    var user = Provider.of<ManagerProvider>(context, listen: false).user;
    var eventManager = Provider.of<ManagerProvider>(context, listen: true).eventManager;

    return Scaffold(
      appBar: _buildAppbar(context, user),
      body: widget.listTimereports != null
          ? _buildMultipleBody(user, eventManager)
          : _buildBody(widget.timereport!, user, eventManager),
    );
  }

  Widget _buildMultipleBody(UserParameters user, EventManager eventManager) {
    PageController pageController = PageController();
    return Stack(
      children: [
        PageView(
          controller: pageController,
          children: List.generate(
            widget.listTimereports!.length,
            (index) {
              var timereport = widget.listTimereports![index];
              return Padding(
                padding: const EdgeInsets.only(left: 0.0, right: 0, top: 0.0, bottom: 48),
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                  child: _buildBody(timereport, user, eventManager),
                ),
              );
            },
          ),
        ),
        Positioned(
          right: 0,
          left: 0,
          bottom: 24,
          child: DotsIndicator(
            color: Theme.of(context).colorScheme.secondary,
            controller: pageController,
            itemCount: widget.listTimereports!.length,
          ),
        )
      ],
    );
  }

  Widget _buildBody(TimeReport timereport, UserParameters user, EventManager eventManager) {
    Event? event = eventManager.getEventForKey(key: timereport.eventId);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0, top: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildParameter(
                iconData: Icons.access_time,
                title: dateToYearMonthDay(timereport.startDate),
                subtitle: '${dateToHourMinute(timereport.startDate)} - ${dateToHourMinute(timereport.endDate)}'),
            _buildParameter(iconData: Icons.access_time, title: "Tid", subtitle: _getTimeSubtitle(timereport)),
            _buildParameter(iconData: Icons.access_alarm, title: "Rast", subtitle: '${timereport.breakTime.toString()} minuter'),
            ConditionalWidget(
              condition: timereport.comment != "",
              childTrue: _buildParameter(iconData: Icons.event_note, title: 'Anteckningar', subtitle: timereport.comment!),
              childFalse: Container(),
            ),
            _buildCost(timereport),
            _buildImageList(timereport, user),
            _buildEventInfo(event)
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    List<String> actions = widget.timereport != null ? actionsSingleTimereport : actionsMultipleTimereport;
    return [
      PopupMenuButton<String>(
        icon: Icon(Icons.more_horiz, color: Colors.white),
        color: Colors.white,
        onSelected: (value) {
          this.handleClick(value);
          //Navigator.of(context).pop();
        },
        itemBuilder: (BuildContext context) {
          return actions.map((String choice) {
            return PopupMenuItem<String>(
              value: choice,
              child: Text(choice),
            );
          }).toList();
        },
      ),
    ];
  }

  String _getTimeSubtitle(TimeReport timereport) {
    int hours = timereport.endDate.difference(timereport.startDate).inHours;
    String hourString = hours == 1 ? '1 timme' : '$hours timmar';

    int minutes = timereport.endDate.difference(timereport.startDate).inMinutes - (hours * 60);
    String minuteString = '$minutes minuter';
    if (minutes == 0) return hourString;
    if (hours == 0) return minuteString;
    return '$hourString $minutes minuter';
  }

  void _markTimereportsDone(List<TimeReport> timereports, FirebaseTimeReportManager fbTimereportManager) async {
    timereports.forEach((timereport) async {
      timereport.isCompleted = true;
      await fbTimereportManager.changeTimereport(timereport);
    });
  }

  void _markTimereportDone(TimeReport timereport, FirebaseTimeReportManager fbTimereportManager) async {
    timereport.isCompleted = true;
    await fbTimereportManager.changeTimereport(timereport);
  }

  void goToCreateInvoiceScreen() {
    Future.delayed(Duration(milliseconds: 800)).then((value) {
      pushNewScreen(context, screen: GenerateInvoiceScreen());
    });
  }

  void handleClick(String value) {
    switch (value) {
      case 'Markera färdiga':
        FirebaseTimeReportManager fbTimereportManager =
            Provider.of<ManagerProvider>(context, listen: false).firebaseTimereportManager;
        //this.widget.didTapCopyEvent(this.widget.event);
        break;
      case 'Markera färdig':
        FirebaseTimeReportManager fbTimereportManager =
            Provider.of<ManagerProvider>(context, listen: false).firebaseTimereportManager;
        _markTimereportDone(widget.timereport!, fbTimereportManager);
        break;
      case 'Ta bort':
        handleDeleteTimereport();
        //widget.firebaseEventManager.removeEvent(widget.event);
        break;
      case 'Skapa faktura':
        goToCreateInvoiceScreen();
    }
  }

  void onDelete() {
    context.loaderOverlay.show();
    Provider.of<ManagerProvider>(context, listen: false)
        .firebaseTimereportManager
        .removeTimereport(widget.timereport!)
        .then((value) {
      context.loaderOverlay.hide();
      Future.delayed(Duration(milliseconds: 500)).then((value) => Navigator.of(context).pop());
    });
  }

  void handleDeleteTimereport() {
    showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: new Text("Ta bort tidrapport"),
              content: new Text("Är du säker på att du vill ta bort den här tidrapporten?"),
              actions: <Widget>[
                CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: Text("Ja"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete();
                    }),
                CupertinoDialogAction(
                  child: Text("Nej"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ));
  }

  Widget _buildCost(TimeReport timereport) {
    var costs = timereport.costs;
    if (costs == null) return Container();
    if (costs.isEmpty) return Container();
    return ListedParameter(
      iconData: Icons.money,
      child: Table(
        columnWidths: const <int, TableColumnWidth>{
          0: IntrinsicColumnWidth(),
          1: IntrinsicColumnWidth(),
          2: IntrinsicColumnWidth()
        },
        children: [
              TableRow(children: [
                Row(
                  children: [
                    Text("Utgift", style: greyText),
                    SizedBox(width: 16.0),
                  ],
                ),
                Row(
                  children: [
                    Text("Antal", style: greyText),
                    SizedBox(width: 16.0),
                  ],
                ),
                Text("Kostnad", style: greyText)
              ]),
            ] +
            List.generate(costs.length, (index) {
              var cost = costs[index];
              return TableRow(
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5.0),
                          Text(cost.description, style: TextStyle(fontSize: 17.0)),
                        ],
                      ),
                      SizedBox(width: 16.0),
                    ],
                  ),
                  TableCell(
                    child: Column(
                      children: [
                        SizedBox(height: 7.0),
                        Row(
                          children: [SizedBox(width: 12), Text(cost.amount.toString())],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5.0),
                      Text(cost.cost.toString() + " kr", style: TextStyle(fontSize: 17.0)),
                    ],
                  ),
                ],
              );
            }),
      ),
    );
  }

  Widget _buildEventInfo(Event? event) {
    if (event == null) {
      print("EVENT IS NULL LOL!");
      return Container();
    }
    return Column(
      children: [
        _buildParameter(iconData: Icons.location_city, title: "Plats", subtitle: event.location ?? ""),
        _buildParameter(iconData: Icons.business, title: "Kund", subtitle: event.customer ?? ""),
        event.notes.isNotBlank()
            ? _buildParameter(iconData: Icons.event_note, title: "Arbetsorder anteckning", subtitle: event.notes ?? "")
            : Container(),
      ],
    );
  }

  Widget _buildParameter({required IconData iconData, required String title, required String subtitle}) {
    return ListedParameter(
        iconData: iconData,
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: greyText,
              ),
              SizedBox(
                width: 25,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 16.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 10,
              )
            ],
          ),
        ));
  }

  Widget _buildImageList(TimeReport timereport, UserParameters user) {
    if (timereport.imagesList == null) return Container();
    if (timereport.imagesList!.isEmpty) return Container();
    return ListedParameter(
        iconData: Icons.image,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Bilder"),
            SizedBox(height: 5.0),
            FutureImageListWidget(
                key: _key, paths: timereport.imagesList!, firebaseStorageManager: FirebaseStorageManager(company: user.company))
          ],
        ));
  }
}
