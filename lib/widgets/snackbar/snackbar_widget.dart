import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';

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
          isSuccess ? _successIcon() : _errorIcon(),
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

  Widget _successIcon() {
    return Container(
      height: 32,
      width: 32,
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          FontAwesome5.check,
          size: 16,
          color: Colors.white,
        ),
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

void showSnackbar({
  required BuildContext context,
  required bool isSuccess,
  required String message,
}) {
  final snackBar = SnackBar(
    backgroundColor: Colors.black.withOpacity(0.9),
    content: SnackbarWidget(
      isSuccess: isSuccess,
      message: message,
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
