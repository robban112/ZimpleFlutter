import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

class FloatingAddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FloatingAddButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'floating_add',
      elevation: 5,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      child: Icon(
        FontAwesome5.plus,
        color: Colors.white,
        size: 22,
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
    );
  }
}
