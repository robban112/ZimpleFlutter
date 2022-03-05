import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:zimple/utils/theme_manager.dart';

class DeleteButton extends StatelessWidget {
  final VoidCallback onTapDelete;
  const DeleteButton({
    Key? key,
    required this.onTapDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onTapDelete,
      child: Container(
        decoration: BoxDecoration(
          color: ThemeNotifier.of(context).red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(FeatherIcons.trash2, color: ThemeNotifier.of(context).red),
        ),
      ),
    );
  }
}
