import 'package:flutter/material.dart';

class ImageDialog extends StatelessWidget {
  final Image image;
  ImageDialog({required this.image});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: InteractiveViewer(
        panEnabled: false, // Set it to false
        boundaryMargin: EdgeInsets.all(100),
        minScale: 0.2,
        maxScale: 5,
        child: this.image,
      ),
    );
    return Dialog(
      child: Container(
        child: image,
      ),
    );
  }
}
