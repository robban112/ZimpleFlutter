import 'package:flutter/material.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import '../../model/event.dart';
import '../../utils/date_utils.dart';
import '../../network/firebase_event_manager.dart';
import 'package:loader_overlay/loader_overlay.dart';

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14.0,
                    ),
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
            )
          ],
        ),
        SizedBox(
          height: 25,
        )
      ],
    );
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

  @override
  Widget build(BuildContext context) {
    print("Rebuild Event Detail screen");
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: event.color,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15.0, top: 25.0),
        child: Container(
          child: Column(
            children: [
              _buildParameter(
                  iconData: Icons.access_time,
                  title: dateToYearMonthDay(event.start),
                  subtitle:
                      '${dateToHourMinute(event.start)} - ${dateToHourMinute(event.end)}'),
              _buildParameter(
                  iconData: Icons.person,
                  title: 'Personer',
                  subtitle: event.persons.map((e) => e.name).join(", ")),
              event.location != ""
                  ? _buildParameter(
                      iconData: Icons.location_city,
                      title: 'Plats',
                      subtitle: event.customer)
                  : Container(),
              event.phoneNumber != ""
                  ? _buildParameter(
                      iconData: Icons.phone,
                      title: 'Telefonnummer',
                      subtitle: event.phoneNumber)
                  : Container(),
              event.notes != ""
                  ? _buildParameter(
                      iconData: Icons.event_note,
                      title: 'Anteckningar',
                      subtitle: event.notes)
                  : Container(),
              _buildImageList(),
              Expanded(child: Container()),
              ListTile(
                leading: Icon(Icons.create),
                title: Text("Ändra event"),
                contentPadding: contentPadding,
                onTap: () {
                  Navigator.pop(context);
                  this.didTapChangeEvent(this.event);
                },
              ),
              ListTile(
                leading: Icon(Icons.content_copy),
                title: Text("Kopiera event"),
                onTap: () {
                  this.didTapCopyEvent(this.event);
                  Navigator.pop(context);
                },
                contentPadding: contentPadding,
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text("Ta bort event"),
                onTap: () {
                  context.showLoaderOverlay();
                  firebaseEventManager.removeEvent(event).then((value) {
                    context.hideLoaderOverlay();
                    Navigator.pop(context);
                  });
                },
                contentPadding: contentPadding,
              ),
              SizedBox(height: 15.0)
            ],
          ),
        ),
      ),
    );
  }
}

class FutureImageListWidget extends StatelessWidget {
  final List<String> paths;
  final FirebaseStorageManager firebaseStorageManager;
  FutureImageListWidget(
      {Key key, @required this.paths, @required this.firebaseStorageManager})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,
      width: MediaQuery.of(context).size.width - 100,
      child: ListView.separated(
          separatorBuilder: (context, index) {
            return SizedBox(width: 10.0);
          },
          scrollDirection: Axis.horizontal,
          itemCount: paths.length,
          itemBuilder: (context, index) {
            return FutureImageWidget(
              path: paths[index],
              firebaseStorageManager: firebaseStorageManager,
            );
          }),
    );
  }
}

class FutureImageWidget extends StatefulWidget {
  final String path;
  final FirebaseStorageManager firebaseStorageManager;
  FutureImageWidget(
      {Key key, @required this.path, @required this.firebaseStorageManager})
      : super(key: key);
  @override
  _FutureImageWidgetState createState() => _FutureImageWidgetState();
}

class _FutureImageWidgetState extends State<FutureImageWidget>
    with AutomaticKeepAliveClientMixin<FutureImageWidget> {
  @override
  bool get wantKeepAlive => true;
  Future<Image> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = widget.firebaseStorageManager.getImage(widget.path);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return KeyedSubtree(
      key: GlobalKey(),
      child: FutureBuilder(
          future: _imageFuture,
          builder: (context, AsyncSnapshot<Image> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) => ImageDialog(image: snapshot.data));
                },
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  height: 125,
                  width: 80,
                  child: snapshot.data,
                ),
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}

class ImageDialog extends StatelessWidget {
  final Image image;
  ImageDialog({@required this.image});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        child: image,
      ),
    );
  }
}
