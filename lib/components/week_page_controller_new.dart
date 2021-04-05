import 'dart:async';
import 'package:zimple/utils/event_manager.dart';
import 'package:flutter/material.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'week_view.dart';
import '../model/event.dart';
import '../utils/date_utils.dart';
import '../utils/days_changed_controller.dart';
import '../utils/date_utils.dart';

typedef List<Event> EventCallback(DateTime date, int numberOfDays);
typedef void DaysChanged(int prevNumberOfDays, int newNumberOfDays);

class WeekPageControllerNew extends StatelessWidget {
  final double _minuteHeight;
  final int _numberOfDays;
  final DaysChangedController daysChangedController;
  //final List<Event> events;
  final Function(Event) didTapEvent;
  final Function(DateTime, int) didTapHour;
  final EventManager eventManager;

  WeekPageControllerNew(
      {Key key,
      @required double minuteHeight,
      @required int numberOfDays,
      @required this.eventManager,
      @required this.didTapEvent,
      this.daysChangedController,
      this.didTapHour})
      : _minuteHeight = minuteHeight,
        _numberOfDays = numberOfDays,
        super(key: key);

  Widget buildContainer(DateTime date) {
    return WeekView(
      numberOfDays: _numberOfDays,
      minuteHeight: _minuteHeight,
      dates: _getDateList(date, _numberOfDays),
      events: eventManager.getEventByStartDate(date, _numberOfDays),
      didTapEvent: didTapEvent,
      didTapHour: didTapHour,
    );
  }

  List<DateTime> _getDateList(DateTime startDate, int daysForward) {
    List<DateTime> dates = [];
    for (var i = 0; i < daysForward; i++) {
      dates.add(startDate.add(Duration(days: i)));
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    print("Rebuilt WeekPageController");
    return InnerWeekPageController(
      screenWidth: width,
      widgetBuilder: buildContainer,
      numberOfDays: _numberOfDays,
      daysChangedController: daysChangedController,
    );
  }
}

class InnerWeekPageController extends StatefulWidget {
  final double screenWidth;
  final int numberOfDays;
  final WidgetBuilder widgetBuilder;
  final DaysChangedController daysChangedController;
  InnerWeekPageController(
      {Key key,
      this.screenWidth,
      this.widgetBuilder,
      this.numberOfDays,
      this.daysChangedController})
      : super(key: key);
  @override
  _InnerWeekPageControllerState createState() =>
      _InnerWeekPageControllerState(UniqueKey(), daysChangedController);
}

typedef Widget WidgetBuilder(DateTime date);

class _InnerWeekPageControllerState extends State<InnerWeekPageController> {
  List<Widget> pages = [];
  ScrollController sc;
  int lowerCount;
  int upperCount;
  bool hasFinishedInitialScroll = false;
  DateTime dateAggregator;
  int pageOffset = 12;
  int currentPage = 0;
  UniqueKey key;

  _InnerWeekPageControllerState(
      Key key, DaysChangedController daysChangedController) {
    daysChangedController.daysChanged = daysChanged;
    this.key = key;
  }

  @override
  void dispose() {
    super.dispose();
    sc.dispose();
    print("disposed Inner Week Page Controller");
  }

  @override
  void initState() {
    super.initState();
    dateAggregator = firstDayOfWeek(DateTime.now());
    sc = ScrollController(
        initialScrollOffset: widget.screenWidth * (pageOffset));
  }

  void daysChanged(int prevNumberOfDays, int newNumberOfDays) {
    if (!sc.hasClients) {
      return;
    }
    print("prev: $prevNumberOfDays, new: $newNumberOfDays");
    var _currentPage = currentPage - pageOffset;

    var pageToJump = (_currentPage * prevNumberOfDays ~/ newNumberOfDays);
    pageToJump += pageOffset;
    _jumpToPage(pageToJump);
    print("1, Jump to page: $pageToJump");
  }

  void scrollToOffset(double offset) {
    Future.delayed(Duration(milliseconds: 1), () {
      sc.animateTo(offset,
          duration: Duration(milliseconds: 300), curve: Curves.decelerate);
    });
  }

  void _jumpToPage(int page) {
    var jump = widget.screenWidth * page;
    print("jump: $jump");
    sc.jumpTo(widget.screenWidth * page);
  }

  StreamController<DateTime> streamController = StreamController<DateTime>();

  @override
  Widget build(BuildContext context) {
    print("Building InnerWeekPageController");
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(75.0),
          child: AppBarWidget(
            dateStream: streamController.stream,
          )),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            var page = sc.offset / widget.screenWidth;
            currentPage = page.toInt() - this.pageOffset;
            var diffDaysCurrentDate = currentPage * widget.numberOfDays;
            var first = DateTime.now().add(Duration(days: diffDaysCurrentDate));
            streamController.add(first);
            print("Page: $currentPage");
          }
        },
        child: ListView.builder(
          controller: sc,
          cacheExtent: 0,
          physics: PageScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            var _index = index - pageOffset;
            return this.widget.widgetBuilder(dateAggregator
                .add(Duration(days: widget.numberOfDays * _index)));
          },
        ),
      ),
    );
  }
}
