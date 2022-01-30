import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:zimple/screens/Calendar/calendar_screen.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'week_view.dart';
import '../model/event.dart';
import '../utils/date_utils.dart';
import '../utils/days_changed_controller.dart';

typedef List<Event> EventCallback(DateTime date, int numberOfDays);
typedef void DaysChanged(int prevNumberOfDays, int newNumberOfDays);

class WeekPageControllerNew extends StatelessWidget {
  final WeekPageController daysChangedController;
  //final List<Event> events;
  final Function(Event) didTapEvent;
  final Function(Event) didLongPressEvent;
  final Function(DateTime, int) didTapHour;
  final Function(DateTime, int) didDoubleTapHour;

  WeekPageControllerNew({
    Key? key,
    required this.didTapEvent,
    required this.daysChangedController,
    required this.didTapHour,
    required this.didDoubleTapHour,
    required this.didLongPressEvent,
  }) : super(key: key);

  Widget buildContainer(BuildContext context, DateTime date) {
    int numberOfDays = CalendarSettings.watch(context).numberOfDays;
    return WeekView(
      numberOfDays: numberOfDays,
      minuteHeight: CalendarSettings.watch(context).minuteHeight,
      dates: getDateRange(date, numberOfDays),
      events: context.read<ManagerProvider>().eventManager.getEventByStartDate(
            date,
            numberOfDays,
          ),
      didTapEvent: didTapEvent,
      didTapHour: didTapHour,
      didDoubleTapHour: didDoubleTapHour,
      didLongPressEvent: didLongPressEvent,
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    int numberOfDays = CalendarSettings.watch(context).numberOfDays;
    print("Rebuilt WeekPageController");
    return InnerWeekPageController(
      screenWidth: width,
      widgetBuilder: (date) => buildContainer(context, date),
      numberOfDays: numberOfDays,
      daysChangedController: daysChangedController,
    );
  }
}

class InnerWeekPageController extends StatefulWidget {
  final double screenWidth;
  final int numberOfDays;
  final WidgetBuilder widgetBuilder;
  final WeekPageController daysChangedController;
  InnerWeekPageController(
      {Key? key,
      required this.screenWidth,
      required this.widgetBuilder,
      required this.numberOfDays,
      required this.daysChangedController})
      : super(key: key);
  @override
  _InnerWeekPageControllerState createState() => _InnerWeekPageControllerState(UniqueKey(), daysChangedController);
}

typedef Widget WidgetBuilder(DateTime date);

class _InnerWeekPageControllerState extends State<InnerWeekPageController> {
  List<Widget> pages = [];
  late ScrollController sc;
  bool hasFinishedInitialScroll = false;
  late DateTime dateAggregator;
  int pageOffset = 12;
  int currentPage = 0;
  Key? key;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamController<DateTime> streamController = StreamController<DateTime>();

  _InnerWeekPageControllerState(Key? key, WeekPageController daysChangedController) {
    daysChangedController.daysChanged = daysChanged;
  }

  @override
  void initState() {
    this.dateAggregator = firstDayOfWeek(DateTime.now());
    this.sc = ScrollController(initialScrollOffset: widget.screenWidth * (pageOffset));
    this.key = key;
    super.initState();
  }

  @override
  void dispose() {
    sc.dispose();
    super.dispose();
    print("disposed Inner Week Page Controller");
  }

  void daysChanged(int prevNumberOfDays, int newNumberOfDays, DateTime? zoomDate) {
    if (!sc.hasClients) {
      return;
    }

    print("currentPage: $currentPage, prevNumberOfDays: $prevNumberOfDays, newNumberOfDays: $newNumberOfDays");
    if (prevNumberOfDays == 1 && newNumberOfDays == 7) {}
    var pageToJump = (currentPage * prevNumberOfDays ~/ newNumberOfDays);
    pageToJump += pageOffset;

    if (zoomDate != null && newNumberOfDays == 1) {
      var date = dateAggregator.add(Duration(days: widget.numberOfDays * currentPage));
      var dates = getDateRange(date, widget.numberOfDays);

      var startDate = dates[0];
      var diff = zoomDate.difference(startDate).inDays;
      if (currentPage < 0) {
        pageToJump -= diff;
      } else {
        pageToJump += diff;
      }
    }

    _jumpToPage(pageToJump);
    if (zoomDate != null) streamController.add(zoomDate);
    print("1, Jump to page: $pageToJump");
  }

  void scrollToOffset(double offset) {
    Future.delayed(Duration(milliseconds: 1), () {
      sc.animateTo(offset, duration: Duration(milliseconds: 300), curve: Curves.decelerate);
    });
  }

  void _jumpToPage(int page) {
    var jump = widget.screenWidth * page;
    print("jump: $jump");
    sc.jumpTo(widget.screenWidth * page);
  }

  @override
  Widget build(BuildContext context) {
    print("Building InnerWeekPageController");
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75.0),
        child: AppBarWidget(
          hasMenu: true,
          dateStream: streamController.stream,
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: ListView.builder(
          controller: sc,
          cacheExtent: 0,
          physics: PageScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            var _index = index - pageOffset;
            return this.widget.widgetBuilder(dateAggregator.add(Duration(days: widget.numberOfDays * _index)));
          },
        ),
      ),
    );
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      var page = sc.offset / widget.screenWidth;
      currentPage = page.toInt() - this.pageOffset;

      var today = DateTime.now();

      var diffDaysCurrentDate = currentPage * widget.numberOfDays - (today.weekday - 1);
      var first = today.add(Duration(days: diffDaysCurrentDate));

      print('First date in current week is: ${first.toString()}');
      streamController.add(first);
      print("Page: $currentPage");
    }
    return false;
  }
}
