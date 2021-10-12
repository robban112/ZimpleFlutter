import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zimple/utils/constants.dart';
import '../utils/date_utils.dart';
import '../screens/TimeReporting/add_timereport_screen.dart';

class DateSelectorController {
  DateTime? initialDate;
  late DateTime Function() getDate;
  late void Function(DateTime) setDate;
}

class StartEndDateSelector extends StatefulWidget {
  final CupertinoDatePickerMode datePickerMode;
  final DateSelectorController startDateSelectorController;
  final DateSelectorController endDateSelectorController;
  final Function(DateTime) onChangeStart;
  final Function(DateTime) onChangeEnd;
  final Color color;
  final EdgeInsets rowInset;
  final bool hidesSeparatorByDefault;
  final bool hidesLastSeparator;
  final bool startEndFollowSameDay;
  final String dateFormat;
  final String startTitle;
  final String endTitle;
  StartEndDateSelector(
      {Key? key,
      required this.startDateSelectorController,
      required this.endDateSelectorController,
      required this.onChangeStart,
      required this.onChangeEnd,
      this.color = Colors.white,
      this.rowInset = EdgeInsets.zero,
      this.hidesSeparatorByDefault = false,
      this.hidesLastSeparator = false,
      this.datePickerMode = CupertinoDatePickerMode.dateAndTime,
      this.dateFormat = 'dd MMMM kk:mm',
      this.startEndFollowSameDay = true,
      this.startTitle = "Startar",
      this.endTitle = "Slutar"})
      : super(key: key);
  @override
  _StartEndDateSelectorState createState() => _StartEndDateSelectorState(startDateSelectorController, endDateSelectorController);
}

class _StartEndDateSelectorState extends State<StartEndDateSelector> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late DateSelectorController startDateSelectorController;
  late DateSelectorController endDateSelectorController;
  bool isShowingStartSelector = false;
  bool isShowingEndSelector = false;
  late DateTime start;
  late DateTime end;

  _StartEndDateSelectorState(
      DateSelectorController startDateSelectorController, DateSelectorController endDateSelectorController) {
    this.startDateSelectorController = startDateSelectorController;
    this.endDateSelectorController = endDateSelectorController;
    startDateSelectorController.getDate = () => getStartDate;
    startDateSelectorController.setDate = setStartDate;
    endDateSelectorController.getDate = () => getEndDate;
    endDateSelectorController.setDate = setEndDate;
  }

  void setStartDate(DateTime start) => setState(() => this.start = start);

  void setEndDate(DateTime end) => setState(() => this.end = end);

  DateTime get getStartDate => start;

  DateTime get getEndDate => end;

  @override
  void initState() {
    print("init state StartEndDateSelector");
    var now = DateTime.now();
    start = startDateSelectorController.initialDate ?? DateTime(now.year, now.month, now.day, 8, 0, 0);
    end = endDateSelectorController.initialDate ?? DateTime(now.year, now.month, now.day, 16, 0, 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildStartDateSelector(),
        //SizedBox(height: 4),
        buildEndDateSelector(),
      ],
    );
  }

  DateSelector buildEndDateSelector() {
    return DateSelector(
        widget.endTitle,
        end,
        (date) {
          _onChangeEndDate(date);
        },
        isShowingEndSelector,
        () {
          setState(() {
            isShowingEndSelector = !isShowingEndSelector;
            isShowingStartSelector = false;
          });
        },
        color: widget.color,
        rowInset: widget.rowInset,
        hidesSeparator: true,
        datePickerMode: widget.datePickerMode,
        dateFormat: widget.dateFormat);
  }

  DateSelector buildStartDateSelector() {
    return DateSelector(
        widget.startTitle,
        start,
        (date) {
          _onChangeStartDate(date);
        },
        isShowingStartSelector,
        () {
          setState(() {
            isShowingStartSelector = !isShowingStartSelector;
            isShowingEndSelector = false;
          });
        },
        color: widget.color,
        rowInset: widget.rowInset,
        datePickerMode: widget.datePickerMode,
        dateFormat: widget.dateFormat);
  }

  void _onChangeEndDate(DateTime date) {
    setState(() {
      end = date;
      if (widget.startEndFollowSameDay && !start.isSameDate(end)) {
        start = DateTime(end.year, end.month, end.day, start.hour, start.minute);
      } else if (start.isAfter(end)) {
        setState(() {
          start = DateTime(end.year, end.month, end.day, start.hour, start.minute);
        });
        if (start.isAfter(end)) {
          setState(() {
            start = end;
          });
        }
        widget.onChangeStart(start);
      }
      widget.onChangeEnd(end);
    });
  }

  void _onChangeStartDate(DateTime date) {
    setState(() {
      start = date;
      if (widget.startEndFollowSameDay && !start.isSameDate(end)) {
        end = DateTime(start.year, start.month, start.day, end.hour, end.minute);
      } else if (start.isAfter(end)) {
        setState(() {
          end = DateTime(start.year, start.month, start.day, end.hour, end.minute);
        });
        if (start.isAfter(end)) {
          setState(() {
            end = start;
          });
        }
        widget.onChangeEnd(end);
      }
      widget.onChangeStart(start);
    });
  }
}

class DateSelector extends StatelessWidget {
  final String title;
  final DateTime date;
  final Function(DateTime) didSelectDate;
  final CupertinoDatePickerMode datePickerMode;
  final bool isShowingDatePicker;
  final Function didTapDateRow;
  final Color color;
  final EdgeInsets rowInset;
  final bool hidesSeparator;
  final String dateFormat;
  DateSelector(this.title, this.date, this.didSelectDate, this.isShowingDatePicker, this.didTapDateRow,
      {this.color = Colors.white,
      this.rowInset = EdgeInsets.zero,
      this.hidesSeparator = false,
      this.datePickerMode = CupertinoDatePickerMode.dateAndTime,
      this.dateFormat = 'dd MMMM kk:mm'});

  @override
  Widget build(BuildContext context) {
    print("build date selector");
    return Column(
      children: [_buildTimeRow(context), buildAnimatedContainer(context)],
    );
  }

  String dateString(DateTime date) {
    DateFormat formatter = DateFormat(dateFormat, locale);
    return formatter.format(date);
  }

  Widget _buildTimeRow(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => didTapDateRow(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time),
                      SizedBox(width: 16.0),
                      Text(title, style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Row(
                    children: [
                      Text(dateString(date), style: TextStyle(fontSize: 15)),
                      Icon(isShowingDatePicker ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down)
                    ],
                  )
                ],
              ),
            ),
            hidesSeparator
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Container(height: 0.3, color: Theme.of(context).dividerColor.withOpacity(0.3)),
                  )
          ],
        ),
      ),
    );
  }

  Widget buildTimeRow() {
    return GestureDetector(
      onTap: () {
        didTapDateRow();
      },
      child: TimereportRow(
        title,
        Row(
          children: [
            Text(
              dateString(date),
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
            SizedBox(width: 6.0),
            Icon(isShowingDatePicker ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down)
          ],
        ),
        color: this.color,
        hidesSeparatorByDefault: hidesSeparator,
      ),
    );
  }

  AnimatedContainer buildAnimatedContainer(BuildContext context) {
    MediaQuery.of(context).size.width;
    return AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: isShowingDatePicker ? 250 : 0.000000000001,
        width: MediaQuery.of(context).size.width,
        child: SizedBox(
          height: isShowingDatePicker ? 250 : 0.000000000001,
          width: MediaQuery.of(context).size.width,
          child: CupertinoTheme(
            data: CupertinoThemeData(brightness: Theme.of(context).brightness),
            child: CupertinoDatePicker(
              key: isShowingDatePicker ? null : UniqueKey(),
              mode: datePickerMode,
              initialDateTime: date,
              minuteInterval: 5,
              onDateTimeChanged: (date) {
                didSelectDate(date);
              },
              use24hFormat: true,
            ),
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
