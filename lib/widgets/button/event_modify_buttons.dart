import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/widgets.dart';

class EventModifyButtons extends StatelessWidget {
  final bool visible;

  final VoidCallback onTapCancel;

  final VoidCallback onTapCopy;

  final VoidCallback onTapMove;

  final VoidCallback onTapChange;

  final VoidCallback onTapDelete;

  const EventModifyButtons({
    Key? key,
    required this.visible,
    required this.onTapCancel,
    required this.onTapCopy,
    required this.onTapMove,
    required this.onTapChange,
    required this.onTapDelete,
  }) : super(key: key);

  ImageFilter get blurred => ImageFilter.blur(sigmaX: 2, sigmaY: 2);

  ImageFilter get normal => ImageFilter.blur(sigmaX: 0, sigmaY: 0);

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 200),
      bottom: visible ? 16 : -500,
      right: 16.0,
      left: 16.0,
      child: BackdropFilter(
        filter: visible ? blurred : normal,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DragupButton(onTap: onTapChange, title: "Ändra"),
            divider(),
            DragupButton(onTap: onTapCopy, title: "Kopiera"),
            divider(),
            DragupButton(onTap: onTapMove, title: "Flytta"),
            divider(),
            DragupButton(onTap: onTapDelete, title: "Ta bort"),
            divider(),
            DragupButton(
                onTap: onTapCancel,
                title: "Avbryt",
                color: ThemeNotifier.of(context).red.withOpacity(0.15),
                textColor: ThemeNotifier.of(context).red),
          ],
        ),
      ),
    );
  }

  divider() => const SizedBox(height: 4);
}
