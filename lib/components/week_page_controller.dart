// import 'package:flutter/material.dart';
// import 'week_view.dart';
// import '../model/event.dart';

// typedef List<Event> EventCallback(int i);

// class WeekPageController extends StatefulWidget {
//   final double _minuteHeight;
//   final int _numberOfDays;
//   final EventCallback getEventsForWeek;
//   WeekPageController(
//       {@required double minuteHeight,
//       @required int numberOfDays,
//       @required this.getEventsForWeek})
//       : _minuteHeight = minuteHeight,
//         _numberOfDays = numberOfDays;
//   @override
//   _WeekPageControllerState createState() => _WeekPageControllerState();
// }

// class _WeekPageControllerState extends State<WeekPageController> {
//   static const initialPage = 1;
//   List<Widget> _pages = [];
//   PageController pageController = PageController(initialPage: initialPage);
//   int currentWeekIndex = 0;
//   int currentPageId = initialPage;
//   int _lowerBound = -1;
//   int _upperBound = 1;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _pages = [
//       WeekView(
//         numberOfDays: widget._numberOfDays,
//         minuteHeight: widget._minuteHeight,
//         weekIndex: _lowerBound,
//         events: widget.getEventsForWeek(_lowerBound),
//       ),
//       WeekView(
//         numberOfDays: widget._numberOfDays,
//         minuteHeight: widget._minuteHeight,
//         weekIndex: 0,
//         events: widget.getEventsForWeek(0),
//       ),
//       WeekView(
//         numberOfDays: widget._numberOfDays,
//         minuteHeight: widget._minuteHeight,
//         weekIndex: _upperBound,
//         events: widget.getEventsForWeek(_upperBound),
//       )
//     ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PageView(
//       children: _pages,
//       controller: pageController,
//       onPageChanged: _onPageChanged,
//     );
//   }

//   void _onPageChanged(int pageId) {
//     print("ON PAGE CHANGED $pageId");
//     currentWeekIndex =
//         currentPageId > pageId ? currentWeekIndex + 1 : currentWeekIndex - 1;
//     currentPageId = pageId;
//     if (pageId == _pages.length - 1) {
//       print("Last page, add page to end");
//       setState(() {
//         _upperBound += 1;
//       });
//       Widget w = WeekView(
//         numberOfDays: widget._numberOfDays,
//         minuteHeight: widget._minuteHeight,
//         weekIndex: _upperBound,
//         events: widget.getEventsForWeek(_upperBound),
//       );
//       setState(() {
//         _pages.add(w);
//       });
//     }
//     if (pageId == 0) {
//       print("First page, add page to start");
//       setState(() {
//         _lowerBound -= 1;
//       });

//       Widget w = WeekView(
//         numberOfDays: widget._numberOfDays,
//         minuteHeight: widget._minuteHeight,
//         weekIndex: _lowerBound,
//         events: widget.getEventsForWeek(_lowerBound),
//       );

//       setState(() {
//         _pages = [w]..addAll(_pages);
//       });
//     }
//   }
// }
