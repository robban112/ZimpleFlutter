import 'package:zimple/model/event_layout.dart';
import 'package:flutter/material.dart';
import 'package:zimple/widgets/person_circle_avatar.dart';
import '../model/event.dart';
import 'package:zimple/extensions/string_extensions.dart';

class EventContainer extends StatelessWidget {
  //onPress
  final Event event;

  final EventLayout eventLayout;

  final Function(Event) didTapEvent;

  late bool isEventLarge;

  EventContainer({required this.event, required this.eventLayout, required this.didTapEvent});

  final double padding = 5;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    //if (eventLayout.width > screenWidth / 5) isEventLarge = true;

    this.isEventLarge = (eventLayout.width > screenWidth / 5 && eventLayout.height > 200);

    // If the event is large enough to have text
    bool isEventTextable = (eventLayout.width > 18 && eventLayout.height > 30);

    // Compute text color from luminance - Black or white
    Color textColor = _dynamicBlackWhite(event.color);

    double titleHeight = _getTitleHeight(event.title, eventLayout, isEventLarge);

    double descHeight = _getDescHeight(event.customer ?? '', eventLayout, titleHeight);

    return Padding(
      padding: EdgeInsets.only(right: 1.0),
      child: Container(
        height: eventLayout.height,
        width: eventLayout.width - 1.0,
        margin: EdgeInsets.only(top: eventLayout.top, left: eventLayout.left),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: event.color.withAlpha(190),
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          splashColor: Colors.white.withAlpha(190),
          onTap: () => didTapEvent(event),
          child: isEventTextable
              ? Padding(
                  padding: isEventLarge ? EdgeInsets.all(6.0) : EdgeInsets.zero,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTitleDesc(titleHeight, descHeight),
                        isEventLarge ? SizedBox(height: 8.0) : Container(),
                        isEventLarge
                            ? Text(event.customer ?? "",
                                style: TextStyle(
                                  color: textColor,
                                ))
                            : Container(),
                        isEventLarge ? SizedBox(height: 8.0) : Container(),
                        isEventLarge ? ListPersonCircleAvatar(persons: event.persons ?? []) : Container()
                      ],
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Column _buildTitleDesc(double titleHeight, double descHeight) {
    return Column(
      //clipBehavior: Clip.antiAlias,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: titleHeight,
          ),
          child: Text(
            event.title,
            overflow: TextOverflow.clip,
            style: _titleStyle(isEventLarge, event),
          ),
        ),
        //SizedBox(height: 6),
        // eventLayout.height > titleHeight
        //     ? ConstrainedBox(
        //         constraints: BoxConstraints(maxHeight: descHeight),
        //         child: isEventLarge
        //             ? Container()
        //             : Text(
        //                 event.customer ?? "",
        //                 style: _descStyle(),
        //               ),
        //       )
        //     : Container()
      ],
    );
  }

  Color _dynamicBlackWhite(Color color) {
    return color.computeLuminance() < 0.5 ? Colors.white : Colors.black;
  }

  double _getTitleHeight(String text, EventLayout eventLayout, bool isEventLarge) {
    double _textHeight = textHeight(text, _titleStyle(isEventLarge, event), eventLayout.width - padding * 2);
    return _textHeight > eventLayout.height - (padding * 2) ? eventLayout.height - (padding * 2) : _textHeight;
  }

  double _getDescHeight(String text, EventLayout eventLayout, double titleHeight) {
    if (titleHeight > eventLayout.height) return 0;
    double descHeight = textHeight(event.customer ?? '', _descStyle(), eventLayout.width - padding * 2);
    if (titleHeight + descHeight > eventLayout.height) {
      double diff = (titleHeight + descHeight) - eventLayout.height;
      if (descHeight - diff - 10 < 0) return 0;
      return descHeight - diff - 10;
    }
    return descHeight;
  }

  // titleHeight + descHeight > eventHeight
  // descHeight - x => titleHeight + descHeight = eventHeight
  //
  //

  TextStyle _titleStyle(bool isEventLarge, Event event) {
    return TextStyle(
        color: _dynamicBlackWhite(event.color),
        fontWeight: isEventLarge ? FontWeight.bold : FontWeight.w500,
        fontSize: isEventLarge ? 17 : 11);
  }

  TextStyle _descStyle() => TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: 11,
        color: _dynamicBlackWhite(event.color),
      );

  double textHeight(String text, TextStyle style, double textWidth) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final countLines = (textPainter.size.width / textWidth).ceil();
    final height = countLines * textPainter.size.height;
    return height;
  }
}
