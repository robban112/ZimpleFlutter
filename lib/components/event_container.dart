import 'package:zimple/model/event_layout.dart';
import 'package:flutter/material.dart';
import 'package:zimple/widgets/person_circle_avatar.dart';
import '../model/event.dart';

class EventContainer extends StatelessWidget {
  //onPress
  final Event event;
  final EventLayout eventLayout;
  final Function(Event) didTapEvent;
  EventContainer(
      {required this.event,
      required this.eventLayout,
      required this.didTapEvent});
  @override
  Widget build(BuildContext context) {
    var isEventLarge = (eventLayout.width > 120 && eventLayout.height > 200);
    var isEventTextable = (eventLayout.width > 18 && eventLayout.height > 30);
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
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          splashColor: Colors.white.withAlpha(190),
          onTap: () {
            didTapEvent(event);
          },
          child: isEventTextable
              ? Padding(
                  padding: isEventLarge ? EdgeInsets.all(6.0) : EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title,
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: isEventLarge ? 17 : 11)),
                      isEventLarge ? SizedBox(height: 8.0) : Container(),
                      isEventLarge ? Text(event.customer ?? "") : Container(),
                      isEventLarge ? SizedBox(height: 8.0) : Container(),
                      isEventLarge
                          ? ListPersonCircleAvatar(persons: event.persons ?? [])
                          : Container()
                    ],
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
