import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<bool> showAlertDialog({
  required BuildContext context,
  required String title,
  required String subtitle,
}) async {
  bool answer = false;
  await showDialog(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(subtitle),
      actions: [
        CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text("Ja"),
            onPressed: () {
              answer = true;
              Navigator.of(context).pop();
            }),
        CupertinoDialogAction(
          child: Text("Nej"),
          onPressed: () {
            answer = false;
            Navigator.of(context).pop();
          },
        )
      ],
    ),
  );
  return answer;
}
