import 'package:zimple/model/event_layout.dart';
import 'package:flutter/material.dart';
import '../model/event.dart';

class EventContainer extends StatelessWidget {
  //onPress
  final Event event;
  final EventLayout eventLayout;
  final Function(Event) didTapEvent;
  EventContainer({this.event, this.eventLayout, this.didTapEvent});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 1.0),
      child: Container(
        height: eventLayout.height,
        width: eventLayout.width - 1.0,
        margin: EdgeInsets.only(top: eventLayout.top, left: eventLayout.left),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: event.color.withAlpha(190),
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: GestureDetector(
          onTap: () {
            didTapEvent(event);
          },
          onLongPress: () {
            print("Long pressed event");
          },
          child: (eventLayout.width > 18 && eventLayout.height > 30)
              ? Text(event.title,
                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 11.0))
              : null,
        ),
      ),
    );
  }
}
