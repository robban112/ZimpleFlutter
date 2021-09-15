import 'package:flutter/material.dart';
import 'package:zimple/network/firebase_storage_manager.dart';
import 'package:zimple/widgets/image_dialog.dart';

class FutureImageListWidget extends StatelessWidget {
  final List<String> paths;
  final FirebaseStorageManager firebaseStorageManager;
  FutureImageListWidget({Key? key, required this.paths, required this.firebaseStorageManager}) : super(key: key);
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
  FutureImageWidget({Key? key, required this.path, required this.firebaseStorageManager}) : super(key: key);
  @override
  _FutureImageWidgetState createState() => _FutureImageWidgetState();
}

class _FutureImageWidgetState extends State<FutureImageWidget> with AutomaticKeepAliveClientMixin<FutureImageWidget> {
  @override
  bool get wantKeepAlive => true;
  late Future<Image?> _imageFuture;

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
          builder: (context, AsyncSnapshot<Image?> snapshot) {
            if (snapshot.data == null) return Center(child: CircularProgressIndicator());
            if (snapshot.connectionState == ConnectionState.done) {
              return GestureDetector(
                onTap: () {
                  showDialog(context: context, builder: (_) => ImageDialog(image: snapshot.data!));
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
