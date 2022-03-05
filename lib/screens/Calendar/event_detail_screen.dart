import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zimple/extensions/string_extensions.dart';
import 'package:zimple/model/models.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/utils/color_utils.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/future_image_widget.dart';
import 'package:zimple/widgets/provider_widget.dart';
import 'package:zimple/widgets/widgets.dart';

import '../../network/firebase_event_manager.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  final FirebaseEventManager firebaseEventManager;
  final FirebaseStorageManager firebaseStorageManager;
  final Function(Event) didTapCopyEvent;
  final Function(Event) didTapChangeEvent;
  final Function(Event) didTapRemoveEvent;
  EventDetailScreen({
    Key? key,
    required this.event,
    required this.firebaseEventManager,
    required this.firebaseStorageManager,
    required this.didTapCopyEvent,
    required this.didTapChangeEvent,
    required this.didTapRemoveEvent,
  }) : super(key: key);

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final _key = GlobalKey();

  final EdgeInsets contentPadding = EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0);

  @override
  Widget build(BuildContext context) {
    print("Rebuild Event Detail screen");
    List<Customer> customers = Provider.of<ManagerProvider>(context, listen: false).customers;
    Customer? customer;
    if (widget.event.customerKey != null) {
      customer = customers.firstWhereOrNull((element) => element.id == widget.event.customerKey);
    }
    var width = MediaQuery.of(context).size.width;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
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
                          color: Theme.of(context).backgroundColor,
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

  Widget _buildParameter(
      {required IconData iconData,
      required String title,
      required String subtitle,
      bool? isRichText,
      VoidCallback? onTapRichText}) {
    return ListedParameter(
        iconData: iconData,
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
            (isRichText ?? false)
                ? RichText(
                    text: TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            if (onTapRichText != null) onTapRichText();
                          },
                        text: subtitle,
                        style: TextStyle(color: Colors.lightBlue, fontSize: 18.0)))
                : (Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 10,
                  ))
          ],
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
          //color: Colors.grey.shade800,
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
                key: _key, paths: widget.event.imageStoragePaths!, firebaseStorageManager: widget.firebaseStorageManager)
          ],
        )
      ],
    );
  }

  Widget _buildPersonListTile(BuildContext context, Person person) {
    bool isDarkMode = Provider.of<ThemeNotifier>(context, listen: true).isDarkMode();
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Row(
        children: [
          ProfilePictureIcon(
            person: person,
            fontSize: 16,
            size: Size(30, 30),
          ),
          SizedBox(width: 16.0),
          Text(person.name),
        ],
      ),
    );
  }

  Widget _buildLocation() {
    if (widget.event.location == null || widget.event.location == "") return Container();
    return ListedParameter(
        iconData: Icons.location_on,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Plats", style: greyText),
            RichText(
                text: TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        print("pressed");
                        MapsLauncher.launchQuery(widget.event.location! + ' Sverige');
                      },
                    text: widget.event.location,
                    style: TextStyle(color: Colors.lightBlueAccent, fontSize: 18.0)))
          ],
        ));
  }

  Widget _buildWorkCategory() {
    if (widget.event.workCategoryId == null) return Container();
    WorkCategory category = WorkCategory(widget.event.workCategoryId!);
    return ListedParameter(
        iconData: category.icon,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Kategori", style: greyText),
            Text(category.name),
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
                  Icon(FeatherIcons.users),
                  SizedBox(width: 25.0),
                  Text(" ${widget.event.persons!.length} personer", style: TextStyle(color: Colors.grey)),
                ],
              ),
              SizedBox(height: 16.0),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(persons!.length, (index) {
                    var person = persons[index];
                    return Column(
                      children: [_buildPersonListTile(context, person), SizedBox(height: 12)],
                    );
                  })),
              SizedBox(height: 12)
            ],
          )
        : Container();
  }

  Widget _buildBody(Customer? customer) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //SizedBox(height: 12.0),
            // _buildParameter(
            //     iconData: Icons.access_time,
            //     title: dateToYearMonthDay(widget.event.start),
            //     subtitle:
            //         '${dateToHourMinute(widget.event.start)} - ${dateToHourMinute(widget.event.end)}'),
            _buildPersonsList(),
            _buildWorkCategory(),
            customer != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildParameter(iconData: FeatherIcons.briefcase, title: 'Kund', subtitle: customer.name),
                    ],
                  )
                : Container(),
            (widget.event.customer != null && widget.event.customer != "")
                ? _buildParameter(iconData: FeatherIcons.briefcase, title: 'Kund fritext', subtitle: widget.event.customer!)
                : Container(),
            _buildLocation(),
            _buildPhoneNumber(),
            _buildContactPerson(),
            _buildNotes(),
            SizedBox(height: 16),
            _buildImageList(),
            SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(double width) {
    var textColor = dynamicBlackWhite(widget.event.color);
    var width = MediaQuery.of(context).size.width;
    bool shouldShowTime = !(widget.event.eventType == EventType.vacation || widget.event.eventType == EventType.sickness);
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(left: 0),
          decoration: BoxDecoration(
            color: widget.event.color,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 8),
                  height: 4,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: width * 0.65),
                              child: Text(widget.event.title,
                                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w900, color: textColor)),
                            ),
                          ],
                        ),
                        buildActions(textColor),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    shouldShowTime
                        ? Text('${dateToHourMinute(widget.event.start)} - ${dateToHourMinute(widget.event.end)}',
                            style: TextStyle(color: textColor.withAlpha(120), fontSize: 20.0, fontWeight: FontWeight.w500))
                        : Container()
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    if (widget.event.notes.isBlank()) return Container();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.event_note),
        const SizedBox(width: 25),
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Container(
              child: Text(widget.event.notes!, textAlign: TextAlign.left),
            )),
      ],
    );
  }

  Widget _buildPhoneNumber() {
    if (widget.event.phoneNumber == null) return Container();
    String? phonenumber = widget.event.phoneNumber?.replaceAll('-', '').replaceAll(' ', '');
    return widget.event.phoneNumber.isNotBlank()
        ? _buildParameter(
            iconData: Icons.phone,
            title: 'Telefonnummer',
            subtitle: widget.event.phoneNumber!,
            isRichText: true,
            onTapRichText: () {
              _makePhoneCall('tel:$phonenumber');
            })
        : Container();
  }

  Widget _buildContactPerson() {
    String? contactKey = widget.event.contactKey;
    if (contactKey.isBlank()) return Container();

    List<Contact> contacts = context.read<ManagerProvider>().contacts;
    Contact? contact = contacts.firstWhereOrNull((c) => c.id == contactKey);
    if (contact == null) return Container();
    return _buildParameter(
        iconData: FeatherIcons.phone,
        title: '${contact.name}',
        isRichText: true,
        subtitle: contact.phoneNumber,
        onTapRichText: () {
          _makePhoneCall('tel:${contact.phoneNumber}');
        });
  }

  Widget buildActions(Color textColor) {
    bool isAdmin = Provider.of<ManagerProvider>(context, listen: false).user.isAdmin;
    return isAdmin
        ? Row(children: [
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
            )
          ])
        : GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Image.asset(
                "images/close.png",
                height: 16,
                width: 16,
              ),
            ),
          );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Kopiera event':
        this.widget.didTapCopyEvent(this.widget.event);
        break;
      case 'Ta bort event':
        widget.didTapRemoveEvent(widget.event);
        break;
    }
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
              //color: Colors.grey.shade800,
            ),
            SizedBox(
              width: 25.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: child,
            )
          ],
        ),
        SizedBox(
          height: 16,
        )
      ],
    );
  }
}
