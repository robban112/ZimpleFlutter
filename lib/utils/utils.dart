import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:loader_overlay/loader_overlay.dart';

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
}
