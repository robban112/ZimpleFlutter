import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zimple/utils/theme_manager.dart';

class PhotoButtons extends StatelessWidget {
  final bool isSelectingPhotoProvider;
  final Function didTapCancel;
  final Function(File) didReceiveImage;
  final picker = ImagePicker();
  PhotoButtons({required this.isSelectingPhotoProvider, required this.didTapCancel, required this.didReceiveImage});
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 200),
      bottom: isSelectingPhotoProvider ? 16 : -300,
      right: 16.0,
      left: 16.0,
      child: BackdropFilter(
        filter: isSelectingPhotoProvider ? blurred : normal,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPhotoButton(context, () {
              getImage(ImageSource.camera);
            }, "Ta foto"),
            SizedBox(height: 4.0),
            _buildPhotoButton(context, () {
              getImage(ImageSource.gallery);
            }, "Välj foto"),
            SizedBox(height: 4.0),
            _buildPhotoButton(context, () {
              didTapCancel();
            }, "Avbryt", color: ThemeNotifier.of(context).red.withOpacity(0.15), textColor: ThemeNotifier.of(context).red),
          ],
        ),
      ),
    );
  }

  ImageFilter get blurred => ImageFilter.blur(sigmaX: 2, sigmaY: 2);

  ImageFilter get normal => ImageFilter.blur(sigmaX: 0, sigmaY: 0);

  Future<void> getImage(ImageSource imageSource) async {
    final pickedFile = await picker.pickImage(source: imageSource).catchError((err) {
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

  Widget _buildPhotoButton(BuildContext context, Function onTap, String text, {Color? color, Color? textColor}) {
    return DragupButton(
      onTap: () => onTap(),
      title: text,
      color: color,
      textColor: textColor,
    );
  }
}

class DragupButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final Color? color;
  final Color? textColor;
  const DragupButton({
    Key? key,
    required this.title,
    required this.onTap,
    this.color,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeNotifier.of(context).photoButtonColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => onTap(),
        child: Container(
          height: 60.0,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: color ?? ThemeNotifier.of(context).photoButtonColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ThemeNotifier.of(context).textColor.withOpacity(0.1)),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor ?? ThemeNotifier.of(context).textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
