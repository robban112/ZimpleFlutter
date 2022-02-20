import 'dart:io';

import 'package:flutter/material.dart';
import 'package:zimple/widgets/image_dialog.dart';

class PreviewImageRow extends StatelessWidget {
  final List<File> selectedImages;
  const PreviewImageRow({
    Key? key,
    required this.selectedImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        children: List.generate(selectedImages.length, (index) {
      var image = selectedImages[index];
      return Row(
        children: [
          Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => ImageDialog(
                        image: Image.file(
                          image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                  child: Image.file(image)))
        ],
      );
    }));
  }
}
