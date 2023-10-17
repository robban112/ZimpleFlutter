import 'package:flutter/cupertino.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:zimple/utils/theme_manager.dart';

class Utils {
  static bool isDarkMode(BuildContext context) {
    return Provider.of<ThemeNotifier>(context, listen: true).isDarkMode();
  }

  static void setLoading(BuildContext context, bool loading) {
    if (loading) {
      context.loaderOverlay.show();
    } else {
      context.loaderOverlay.hide();
    }
  }

  static Future<bool> showAlertDialog(BuildContext context, {required String title, required String subtitle}) async {
    bool confirmed = true;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(subtitle),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              confirmed = false;
              Navigator.pop(context);
            },
            child: const Text('Nej'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              confirmed = true;
              Navigator.pop(context);
            },
            child: const Text('Ja'),
          ),
        ],
      ),
    );
    return confirmed;
  }
}
