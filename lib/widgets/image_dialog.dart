import 'package:flutter/material.dart';

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
