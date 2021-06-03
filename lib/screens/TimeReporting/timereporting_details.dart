import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zimple/model/event.dart';
import 'package:zimple/model/timereport.dart';
import 'package:zimple/model/user_parameters.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/screens/Calendar/event_detail_screen.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:zimple/widgets/conditional_widget.dart';
import 'package:zimple/widgets/future_image_widget.dart';
import 'package:zimple/widgets/provider_widget.dart';

class TimereportingDetails extends StatelessWidget {
  final _key = GlobalKey();
  final TimeReport timereport;
  final Event event;
  TimereportingDetails({this.timereport, this.event});

  AppBar _buildAppbar(BuildContext context) {
    return AppBar(
      backgroundColor: primaryColor,
      elevation: 0.0,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25.0),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<ManagerProvider>(context, listen: false).user;
    return Scaffold(
      appBar: _buildAppbar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, top: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildParameter(
                  iconData: Icons.access_time,
                  title: dateToYearMonthDay(timereport.startDate),
                  subtitle:
                      '${dateToHourMinute(timereport.startDate)} - ${dateToHourMinute(timereport.endDate)}'),
              ConditionalWidget(
                condition: timereport.comment != "",
                childTrue: _buildParameter(
                    iconData: Icons.event_note,
                    title: 'Anteckningar',
                    subtitle: timereport.comment),
                childFalse: Container(),
              ),
              _buildImageList(user),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildImageList(UserParameters user) {
    return timereport.imagesList == null
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
                      paths: timereport.imagesList,
                      firebaseStorageManager:
                          FirebaseStorageManager(company: user.company))
                ],
              )
            ],
          );
  }
}
