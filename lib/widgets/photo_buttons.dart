import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoButtons extends StatelessWidget {
  final bool isSelectingPhotoProvider;
  final Function didTapCancel;
  final Function(File) didReceiveImage;
  final picker = ImagePicker();
  PhotoButtons(
      {required this.isSelectingPhotoProvider,
      required this.didTapCancel,
      required this.didReceiveImage});
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
        duration: Duration(milliseconds: 200),
        bottom: isSelectingPhotoProvider ? 16 : -300,
        right: 16.0,
        left: 16.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPhotoButton(context, () {
              getImage(ImageSource.camera);
            }, "Ta foto"),
            SizedBox(height: 1.0),
            _buildPhotoButton(context, () {
              getImage(ImageSource.gallery);
            }, "Välj foto"),
            SizedBox(height: 5.0),
            _buildPhotoButton(context, () {
              didTapCancel();
            }, "Avbryt"),
          ],
        ));
  }

  Future<void> getImage(ImageSource imageSource) async {
    final pickedFile =
        await picker.getImage(source: imageSource).catchError((err) {
      print("Error retrieving image $err");
    });

    if (pickedFile != null) {
      print("Picked Image");
      didReceiveImage(File(pickedFile.path));
    } else {
      print('No image selected.');
    }
    return;
  }

  Widget _buildPhotoButton(BuildContext context, Function onTap, String text) {
    return Container(
      height: 60.0,
      width: 120,
      color: Theme.of(context).backgroundColor,
      child: ButtonTheme(
        buttonColor: Theme.of(context).backgroundColor,
        height: 60.0,
        child: ElevatedButton(
          child: Text(text, style: TextStyle(fontSize: 17.0)),
          onPressed: () {
            onTap();
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size(100.0, 50.0),
            elevation: 5,
            onPrimary: Theme.of(context).accentColor,
            primary: Theme.of(context).primaryColor,
            //onPrimary: Colors.black,
          ),
        ),
      ),
    );
  }
}
