import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/date_utils.dart';
import '../screens/TimeReporting/add_timereport_screen.dart';

class DateSelectorController {
  DateTime Function() getDate;
}

class StartEndDateSelector extends StatefulWidget {
  final DateTime initialStart;
  final DateTime initialEnd;
  final DateSelectorController startDateSelectorController;
  final DateSelectorController endDateSelectorController;
  final Function(DateTime) onChangeStart;
  final Function(DateTime) onChangeEnd;
  StartEndDateSelector(
      this.initialStart,
      this.initialEnd,
      this.startDateSelectorController,
      this.endDateSelectorController,
      this.onChangeStart,
      this.onChangeEnd);
  @override
  _StartEndDateSelectorState createState() => _StartEndDateSelectorState(
      startDateSelectorController, endDateSelectorController);
}

class _StartEndDateSelectorState extends State<StartEndDateSelector> {
  bool isShowingStartSelector = false;
  bool isShowingEndSelector = false;
  DateTime start;
  DateTime end;

  _StartEndDateSelectorState(DateSelectorController startDateSelectorController,
      DateSelectorController endDateSelectorController) {
    startDateSelectorController.getDate = getStartDate;
    endDateSelectorController.getDate = getEndDate;
  }

  DateTime getStartDate() {
    return start;
  }

  DateTime getEndDate() {
    return end;
  }

  @override
  void initState() {
    var now = DateTime.now();
    start =
        widget.initialStart ?? DateTime(now.year, now.month, now.day, 8, 0, 0);
    end = widget.initialEnd ?? DateTime(now.year, now.month, now.day, 16, 0, 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildStartDateSelector(),
        buildEndDateSelector(),
      ],
    );
  }

  DateSelector buildEndDateSelector() {
    return DateSelector(
        "Sluttid",
        end,
        (date) {
          setState(() {
            end = date;
            if (start.isAfter(end)) {
              start = DateTime(
                  end.year, end.month, end.day, start.hour, start.minute);
              if (start.isAfter(end)) {
                start = end;
              }
              widget.onChangeStart(start);
            }
            widget.onChangeEnd(end);
          });
        },
        isShowingEndSelector,
        () {
          setState(() {
            isShowingEndSelector = !isShowingEndSelector;
            isShowingStartSelector = false;
          });
        });
  }

  DateSelector buildStartDateSelector() {
    return DateSelector(
        "Starttid",
        start,
        (date) {
          setState(() {
            start = date;
            if (start.isAfter(end)) {
              end = DateTime(
                  start.year, start.month, start.day, end.hour, end.minute);
              if (start.isAfter(end)) {
                end = start;
              }
              widget.onChangeEnd(end);
            }
            widget.onChangeStart(start);
          });
        },
        isShowingStartSelector,
        () {
          setState(() {
            isShowingStartSelector = !isShowingStartSelector;
            isShowingEndSelector = false;
          });
        });
  }
}

class DateSelector extends StatelessWidget {
  final String title;
  final DateTime date;
  final Function(DateTime) didSelectDate;
  final bool isShowingDatePicker;
  final Function didTapDateRow;
  DateSelector(this.title, this.date, this.didSelectDate,
      this.isShowingDatePicker, this.didTapDateRow);

  @override
  Widget build(BuildContext context) {
    print("build date selector");
    return Column(
      children: [buildTimeRow(), buildAnimatedContainer()],
    );
  }

  GestureDetector buildTimeRow() {
    return GestureDetector(
      onTap: () {
        didTapDateRow();
      },
      child: TimereportRow(
        title,
        Row(
          children: [
            Text(
              dateStringMonthHourMinute(date),
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
            SizedBox(width: 6.0),
            Icon(isShowingDatePicker
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down)
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildAnimatedContainer() {
    return AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: isShowingDatePicker ? 200 : 0.000000000001,
        child: SizedBox(
          height: isShowingDatePicker ? 200 : 0.000000000001,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.dateAndTime,
            initialDateTime: date,
            minuteInterval: 5,
            onDateTimeChanged: (date) {
              didSelectDate(date);
            },
            use24hFormat: true,
          ),
        ));
  }
}

// class RotationalWidget extends StatefulWidget {
//   final Widget child;
//   final bool rotate;
//   RotationalWidget(this.child, this.rotate);
//   @override
//   _RotationalWidgetState createState() => _RotationalWidgetState();
// }

// class _RotationalWidgetState extends State<RotationalWidget>
//     with TickerProviderStateMixin {
//   AnimationController _controller;
//   Animation<double> _animation;
//   double stateBegin = 1.0;

//   @override
//   initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: Duration(milliseconds: 300),
//       vsync: this,
//     );
//     //_animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
//   }

//   @override
//   dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("build rotate widget ${widget.rotate}");
//     double from = widget.rotate ? pi : 0;
//     _controller.forward(from: from);
//     return AnimatedBuilder(
//       animation: _controller,
//       child: widget.child,
//       builder: (BuildContext context, Widget _widget) {
//         double angle = widget.rotate ? 2 * pi : pi;
//         return new Transform.rotate(
//             angle: _controller.value * angle, child: _widget);
//       },
//     );
//     // return RotationTransition(
//     //     turns: Tween<double>(
//     //             begin: widget.rotate ? 0.75 : 0, end: widget.rotate ? 0 : 0)
//     //         .animate(_controller),
//     //     child: GestureDetector(
//     //         onTap: () {
//     //           _controller.forward(from: 0);
//     //         },
//     //         child: widget.child));
//   }
// }
