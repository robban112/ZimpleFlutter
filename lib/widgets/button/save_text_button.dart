import 'package:flutter/material.dart';

class SaveTextButton extends StatelessWidget {
  final VoidCallback onTapSave;
  const SaveTextButton({
    Key? key,
    required this.onTapSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(
        "Spara",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      onPressed: onTapSave,
    );
  }
}
