import 'package:flutter/material.dart';
import 'package:zimple/widgets/widgets.dart';

class ListedSwitch extends ListedItem {
  final bool initialValue;
  final EdgeInsets? rowInset;
  final Function(bool) onChanged;

  ListedSwitch({
    required String text,
    required this.initialValue,
    required this.onChanged,
    this.rowInset,
    leadingIcon,
  }) : super(
          leadingIcon: leadingIcon,
          text: text,
        );
}
