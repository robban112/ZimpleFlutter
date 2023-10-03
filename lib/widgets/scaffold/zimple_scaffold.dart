import 'package:flutter/material.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/app_bar_widget.dart';

class ZimpleScaffold extends StatelessWidget {
  final String title;

  final Widget body;

  final Widget? trailingTopNav;

  const ZimpleScaffold({required this.title, required this.body, this.trailingTopNav, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: appBarSize,
        child: StandardAppBar(
          title,
          trailing: trailingTopNav,
        ),
      ),
      body: body,
    );
  }
}
