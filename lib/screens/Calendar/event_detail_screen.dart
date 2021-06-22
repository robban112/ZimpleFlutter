import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zimple/model/customer.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/widgets/future_image_widget.dart';
import 'package:zimple/widgets/provider_widget.dart';
import '../../model/event.dart';
import '../../utils/date_utils.dart';
import '../../utils/constants.dart';
import '../../network/firebase_event_manager.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:zimple/utils/color_utils.dart';
import 'package:collection/collection.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  final FirebaseEventManager firebaseEventManager;
  final FirebaseStorageManager firebaseStorageManager;
  final Function(Event) didTapCopyEvent;
  final Function(Event) didTapChangeEvent;
  EventDetailScreen(
      {Key? key,
      required this.event,
      required this.firebaseEventManager,
      required this.firebaseStorageManager,
      required this.didTapCopyEvent,
      required this.didTapChangeEvent})
      : super(key: key);

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final _key = GlobalKey();

  final EdgeInsets contentPadding =
      EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0);

  Widget _buildParameter(
      {required IconData iconData,
      required String title,
      required String subtitle}) {
    return ListedParameter(
        iconData: iconData,
        child: Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 10,
              )
            ],
          ),
        ));
  }

  Widget _buildImageList() {
    if (widget.event.imageStoragePaths == null) return Container();
    if (widget.event.imageStoragePaths!.isEmpty) return Container();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.image,
          size: 28.0,
          color: Colors.grey.shade800,
        ),
        SizedBox(
          width: 25.0,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Bilder"),
            SizedBox(height: 5.0),
            FutureImageListWidget(
                key: _key,
                paths: widget.event.imageStoragePaths!,
                firebaseStorageManager: widget.firebaseStorageManager)
          ],
        )
      ],
    );
  }

  Widget _buildPersonListTile(Person person) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: Colors.grey.shade400,
            child: Center(
              child: Text(
                person.name.characters.first.toUpperCase(),
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.0),
              ),
            ),
          ),
          SizedBox(width: 24.0),
          Text(person.name),
        ],
      ),
    );
  }

  Widget _buildLocation() {
    if (widget.event.location == null || widget.event.location == "")
      return Container();
    return ListedParameter(
        iconData: Icons.location_city,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Plats", style: greyText),
            RichText(
                text: TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        print("pressed");
                        MapsLauncher.launchQuery(
                            widget.event.location! + ' Sverige');
                      },
                    text: widget.event.location,
                    style: TextStyle(
                        color: Colors.lightBlueAccent, fontSize: 18.0)))
          ],
        ));
  }

  Widget _buildPersonsList() {
    var persons = widget.event.persons;
    return (persons?.length ?? 0) > 0
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.group),
                  SizedBox(width: 25.0),
                  Text(" ${widget.event.persons!.length} personer",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
              SizedBox(height: 16.0),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(persons!.length, (index) {
                    var person = persons[index];
                    return Column(
                      children: [
                        _buildPersonListTile(person),
                        SizedBox(height: 12)
                      ],
                    );
                  })),
              SizedBox(height: 12)
            ],
          )
        : Container();
  }

  void handleClick(String value) {
    switch (value) {
      case 'Kopiera event':
        this.widget.didTapCopyEvent(this.widget.event);
        break;
      case 'Ta bort event':
        widget.firebaseEventManager.removeEvent(widget.event);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Rebuild Event Detail screen");
    List<Customer> customers =
        Provider.of<ManagerProvider>(context, listen: false).customers;
    Customer? customer;
    if (widget.event.customerKey != null) {
      customer = customers.firstWhereOrNull(
          (element) => element.id == widget.event.customerKey);
    }
    var width = MediaQuery.of(context).size.width;
    return DraggableScrollableSheet(
      initialChildSize: 0.84,
      minChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (context, controller) {
        return LayoutBuilder(
          builder: (context, constraint) {
            return SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              controller: controller,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraint.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: <Widget>[
                      _buildTitle(width),
                      _buildBody(customer),
                      Expanded(
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(Customer? customer) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
        child: Column(
          children: [
            //SizedBox(height: 12.0),
            // _buildParameter(
            //     iconData: Icons.access_time,
            //     title: dateToYearMonthDay(widget.event.start),
            //     subtitle:
            //         '${dateToHourMinute(widget.event.start)} - ${dateToHourMinute(widget.event.end)}'),
            _buildPersonsList(),
            customer != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildParameter(
                          iconData: Icons.business,
                          title: 'Kund',
                          subtitle: customer.name),
                    ],
                  )
                : Container(),
            _buildLocation(),
            widget.event.phoneNumber != null && widget.event.phoneNumber != ""
                ? _buildParameter(
                    iconData: Icons.phone,
                    title: 'Telefonnummer',
                    subtitle: widget.event.phoneNumber!)
                : Container(),
            widget.event.notes != null && widget.event.notes != ""
                ? _buildParameter(
                    iconData: Icons.event_note,
                    title: 'Anteckningar',
                    subtitle: widget.event.notes!)
                : Container(),
            _buildImageList(),
            // SizedBox(height: 15.0),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(double width) {
    var textColor = dynamicBlackWhite(widget.event.color);
    var width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        // Container(
        //   height: 75,
        //   padding: EdgeInsets.only(left: 0),
        //   decoration: BoxDecoration(
        //       color: widget.event.color,
        //       borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        // ),
        Container(
          //height: 75,
          padding: EdgeInsets.only(left: 0),
          decoration: BoxDecoration(
              color: widget.event.color,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // GestureDetector(
                        //   onTap: () {
                        //     Navigator.pop(context);
                        //   },
                        //   child: CircleAvatar(
                        //     radius: 12,
                        //     backgroundColor: Colors.grey.shade300,
                        //     child: Container(
                        //       height: 8,
                        //       width: 8,
                        //       child: Image.asset("images/close.png"),
                        //     ),
                        //   ),
                        // ),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: width * 0.65),
                          child: Text(widget.event.title,
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: textColor)),
                        ),
                      ],
                    ),
                    buildActions(textColor),
                  ],
                ),
                SizedBox(height: 4.0),
                Text(
                    '${dateToHourMinute(widget.event.start)} - ${dateToHourMinute(widget.event.end)}',
                    style: TextStyle(
                        color: textColor.withAlpha(120),
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500))
              ],
            ),
          ),
        ),
      ],
    );
  }

  Row buildActions(Color textColor) {
    return Row(children: [
      SizedBox(
        height: 26,
        width: 26,
        child: IconButton(
          constraints: BoxConstraints(maxHeight: 15, maxWidth: 15),
          splashRadius: 5,
          padding: EdgeInsets.zero,
          icon: Icon(Icons.edit, color: textColor),
          onPressed: () {
            Navigator.pop(context);
            this.widget.didTapChangeEvent(this.widget.event);
          },
        ),
      ),
      SizedBox(width: 16),
      SizedBox(
        height: 26,
        width: 26,
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          icon: Icon(Icons.more_horiz, color: textColor),
          onSelected: (value) {
            this.handleClick(value);
            Navigator.of(context).pop();
          },
          itemBuilder: (BuildContext context) {
            return {'Kopiera event', 'Ta bort event'}.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        ),
      ),
    ]);
  }

  List<Widget> _buildActions(BuildContext context, Color color) {
    return [
      IconButton(
        icon: Icon(Icons.edit, color: color),
        onPressed: () {
          Navigator.pop(context);
          this.widget.didTapChangeEvent(this.widget.event);
        },
      ),
      PopupMenuButton<String>(
        color: color,
        onSelected: (value) {
          this.handleClick(value);
          Navigator.of(context).pop();
        },
        itemBuilder: (BuildContext context) {
          return {'Kopiera event', 'Ta bort event'}.map((String choice) {
            return PopupMenuItem<String>(
              value: choice,
              child: Text(choice),
            );
          }).toList();
        },
      ),
    ];
  }
}

class ListedParameter extends StatelessWidget {
  final Widget child;
  final IconData iconData;
  ListedParameter({required this.iconData, required this.child});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              iconData,
              size: 28.0,
              color: Colors.grey.shade800,
            ),
            SizedBox(
              width: 25.0,
            ),
            child
          ],
        ),
        SizedBox(
          height: 16,
        )
      ],
    );
  }
}
