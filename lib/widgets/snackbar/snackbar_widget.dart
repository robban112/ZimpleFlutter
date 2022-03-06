import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:zimple/utils/theme_manager.dart';

class SnackbarWidget extends StatelessWidget {
  final bool isSuccess;

  final String message;

  const SnackbarWidget({
    Key? key,
    required this.isSuccess,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          isSuccess ? SuccessIcon() : _errorIcon(),
          const SizedBox(width: 12),
          Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorIcon() {
    return Icon(
      FontAwesome5.exclamation_triangle,
      color: Colors.red,
    );
  }
}

class SuccessIcon extends StatelessWidget {
  final Size size;
  const SuccessIcon({Key? key, this.size = const Size(32, 32)}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height,
      width: size.width,
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          FontAwesome5.check,
          size: 16 * size.width / 32,
          color: Colors.white,
        ),
      ),
    );
  }
}

void showSnackbar({
  required BuildContext context,
  required bool isSuccess,
  required String message,
}) {
  final snackBar = SnackBar(
    backgroundColor: ThemeNotifier.darkThemePrimaryBg,
    content: SnackbarWidget(
      isSuccess: isSuccess,
      message: message,
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
