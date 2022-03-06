import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/date_utils.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/widgets.dart';

class SelectMonthModal extends StatelessWidget {
  static const List<int> months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  final Function(int) onSelectMonth;

  final int selectedMonth;

  const SelectMonthModal({
    Key? key,
    required this.onSelectMonth,
    required this.selectedMonth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Scaffold(
        backgroundColor: Color(0xff0F0E0E).withOpacity(ThemeNotifier.of(context).isDarkMode() ? 0 : 0.6),
        body: SafeArea(
          child: Container(
            height: height(context),
            width: width(context),
            child: Stack(
              children: [
                Center(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      int month = months[index];
                      return _buildMonthRowItem(context, month);
                    },
                    itemCount: months.length,
                  ),
                ),
                Align(alignment: Alignment.topRight, child: ZCloseButton(color: ThemeNotifier.of(context).red)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthRowItem(BuildContext context, int month) {
    bool selected = selectedMonth == month;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _onSelectMonth(context, month),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: selected ? ThemeNotifier.of(context).green : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                getMonthName(month),
                style: textStyle(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            selected
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Icon(
                        FeatherIcons.check,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void _onSelectMonth(BuildContext context, int month) {
    Navigator.of(context).pop();
    onSelectMonth(month);
  }
}
