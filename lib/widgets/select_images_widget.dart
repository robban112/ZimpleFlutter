import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zimple/widgets/photo_buttons.dart';

class SelectImagesWidget extends StatefulWidget {
  final Function(File file) didPickImage;

  final GlobalKey<SelectImagesWidgetState> selectImageKey;

  final Widget child;

  const SelectImagesWidget({
    Key? key,
    required this.selectImageKey,
    required this.didPickImage,
    required this.child,
  }) : super(key: selectImageKey);

  @override
  SelectImagesWidgetState createState() => SelectImagesWidgetState();
}

class SelectImagesWidgetState extends State<SelectImagesWidget> {
  bool isSelectingPhotoProvider = false;

  @override
  Widget build(BuildContext context) {
    return SelectImagesComponent(
      isSelectingPhotoProvider: isSelectingPhotoProvider,
      didPickImage: didPickImage,
      didTapCancel: didTapCancel,
      child: widget.child,
    );
  }

  void didPickImage(File file) {
    setState(() => this.isSelectingPhotoProvider = false);
    widget.didPickImage(file);
  }

  void didTapCancel() {
    setState(() => this.isSelectingPhotoProvider = false);
  }

  void pickImage() {
    setState(() => this.isSelectingPhotoProvider = true);
  }
}

class SelectImagesComponent extends StatelessWidget {
  final bool isSelectingPhotoProvider;

  final Function didTapCancel;

  final Function(File) didPickImage;

  final picker = ImagePicker();

  final Widget child;

  SelectImagesComponent({
    required this.isSelectingPhotoProvider,
    required this.didPickImage,
    required this.didTapCancel,
    required this.child,
  });

  Future getImage(ImageSource imageSource) async {
    final pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      print("Picked Image");
      didPickImage(File(pickedFile.path));
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        PhotoButtons(
          isSelectingPhotoProvider: this.isSelectingPhotoProvider,
          didTapCancel: didTapCancel,
          didReceiveImage: didPickImage,
        ),
      ],
    );
  }
}
