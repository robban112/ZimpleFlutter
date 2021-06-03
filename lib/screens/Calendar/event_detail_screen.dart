import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zimple/model/customer.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/widgets/conditional_widget.dart';
import 'package:zimple/widgets/future_image_widget.dart';
import 'package:zimple/widgets/provider_widget.dart';
import '../../model/event.dart';
import '../../utils/date_utils.dart';
import '../../utils/constants.dart';
import '../../network/firebase_event_manager.dart';
import 'package:maps_launcher/maps_launcher.dart';

class EventDetailScreen extends StatelessWidget {
  final _key = GlobalKey();
  final Event event;
  final FirebaseEventManager firebaseEventManager;
  final FirebaseStorageManager firebaseStorageManager;
  final Function(Event) didTapCopyEvent;
  final Function(Event) didTapChangeEvent;
  EventDetailScreen(
      {Key key,
      @required this.event,
      @required this.firebaseEventManager,
      @required this.firebaseStorageManager,
      this.didTapCopyEvent,
      this.didTapChangeEvent})
      : super(key: key);
  final EdgeInsets contentPadding =
      EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0);

  Widget _buildParameter(
      {@required IconData iconData,
      @required String title,
      @required String subtitle}) {
    return ListedParameter(
        iconData: iconData,
        child: Expanded(
          child: Column(
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
    return event.imageStoragePaths == null
        ? Container()
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.image,
                size: 28.0,
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
                      paths: event.imageStoragePaths,
                      firebaseStorageManager: firebaseStorageManager)
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
    return event.location != ""
        ? ListedParameter(
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
                                event.location + ' Sverige');
                          },
                        text: event.location,
                        style: TextStyle(
                            color: Colors.lightBlueAccent, fontSize: 18.0)))
              ],
            ))
        : Container();
  }

  Widget _buildPersonsList() {
    return event.persons.length > 0
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.group),
                  SizedBox(width: 25.0),
                  Text(" ${event.persons.length} personer",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
              SizedBox(height: 20.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: event.persons.length,
                      itemBuilder: (context, index) {
                        var person = event.persons[index];
                        return _buildPersonListTile(person);
                      },
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 10.0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30)
            ],
          )
        : Container();
  }

  void handleClick(String value) {
    switch (value) {
      case 'Kopiera event':
        this.didTapCopyEvent(this.event);
        break;
      case 'Ta bort event':
        firebaseEventManager.removeEvent(event);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Rebuild Event Detail screen");
    List<Customer> customers =
        Provider.of<ManagerProvider>(context, listen: false).customers;
    Customer customer;
    if (event.customerKey != null) {
      customer = customers.firstWhere((c) => c.id == event.customerKey,
          orElse: () => null);
    }
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: event.color,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.pop(context);
              this.didTapChangeEvent(this.event);
            },
          ),
          PopupMenuButton<String>(
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15.0, top: 25.0),
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                _buildParameter(
                    iconData: Icons.access_time,
                    title: dateToYearMonthDay(event.start),
                    subtitle:
                        '${dateToHourMinute(event.start)} - ${dateToHourMinute(event.end)}'),
                _buildPersonsList(),
                customer != null
                    ? Column(
                        children: [
                          _buildParameter(
                              iconData: Icons.business,
                              title: 'Kund',
                              subtitle: customer.name),
                        ],
                      )
                    : Container(),
                _buildLocation(),
                event.phoneNumber != ""
                    ? _buildParameter(
                        iconData: Icons.phone,
                        title: 'Telefonnummer',
                        subtitle: event.phoneNumber)
                    : Container(),
                ConditionalWidget(
                  condition: event.notes != "",
                  childTrue: _buildParameter(
                      iconData: Icons.event_note,
                      title: 'Anteckningar',
                      subtitle: event.notes),
                  childFalse: Container(),
                ),
                _buildImageList(),
                SizedBox(height: 15.0)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ListedParameter extends StatelessWidget {
  final Widget child;
  final IconData iconData;
  ListedParameter({this.iconData, this.child});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              iconData,
              size: 28.0,
            ),
            SizedBox(
              width: 25.0,
            ),
            child
          ],
        ),
        SizedBox(
          height: 25,
        )
      ],
    );
  }
}
