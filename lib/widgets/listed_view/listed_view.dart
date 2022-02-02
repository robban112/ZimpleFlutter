import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/theme_manager.dart';

class ListedItem {
  final Widget? child;
  final String? text;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Widget? trailingWidget;
  final Widget? leadingWidget;
  final VoidCallback? onTap;
  ListedItem({
    this.child,
    this.text,
    this.leadingIcon,
    this.trailingIcon,
    this.onTap,
    this.trailingWidget,
    this.leadingWidget,
  });
}

class ListedItemWidget extends StatelessWidget {
  const ListedItemWidget(
      {Key? key, required this.item, this.rowInset = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)})
      : super(key: key);

  final ListedItem item;
  final EdgeInsets rowInset;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (item.onTap != null) item.onTap!();
        },
        splashColor: Colors.grey.shade300,
        child: Padding(
          padding: this.rowInset,
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [_leading(), item.text != null ? Text(item.text!, style: TextStyle(fontSize: 16)) : item.child!],
            ),
            Expanded(child: Container()),
            item.trailingWidget != null ? item.trailingWidget! : Icon(Icons.chevron_right)
          ]),
        ),
      ),
    );
  }

  Widget _leading() {
    return (item.leadingIcon != null || item.leadingWidget != null)
        ? Row(
            children: [
              item.leadingWidget ??
                  Icon(
                    item.leadingIcon,
                  ),
              SizedBox(width: 16.0),
            ],
          )
        : Container();
  }
}

class ListedTitle extends StatelessWidget {
  const ListedTitle({Key? key, required this.text}) : super(key: key);

  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
        child: Text(text, style: TextStyle(fontWeight: FontWeight.w500)));
  }
}

class ListedTextField extends ListedItem {
  final String? placeholder;
  final Function(String)? onChanged;
  final GlobalKey<FormState>? key;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType? inputType;
  final bool isMultipleLine;
  ListedTextField({
    this.key,
    leadingIcon,
    this.placeholder,
    this.onChanged,
    this.initialValue = "",
    this.controller,
    this.inputType = TextInputType.text,
    this.isMultipleLine = false,
  }) : super(leadingIcon: leadingIcon, child: Container());
}

class ListedView extends StatelessWidget {
  final List<ListedItem> items;
  final EdgeInsets rowInset;
  final bool isScrollable;
  final bool hidesSeparatorByDefault;
  final bool hidesFirstLastSeparator;
  final double separatorHeight;
  ListedView({
    required this.items,
    this.rowInset = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.isScrollable = false,
    this.hidesSeparatorByDefault = false,
    this.separatorHeight = 0.3,
    this.hidesFirstLastSeparator = true,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          hidesFirstLastSeparator
              ? Container()
              : Container(height: separatorHeight, color: Theme.of(context).dividerColor.withOpacity(0.3)),
          ListView.separated(
            shrinkWrap: true,
            physics: isScrollable ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: _itemBuilder,
            separatorBuilder: _separatorBuilder,
          ),
          hidesFirstLastSeparator
              ? Container()
              : Container(height: separatorHeight, color: Theme.of(context).dividerColor.withOpacity(0.3)),
        ],
      ),
    );
  }

  Widget _separatorBuilder(context, index) {
    ListedItem item = items[index];
    double leftInset = item.leadingIcon != null ? rowInset.left + 42 : rowInset.left;
    return hidesSeparatorByDefault
        ? Container()
        : Padding(
            padding: rowInset.copyWith(top: 0, bottom: 0, left: leftInset, right: 0),
            child: Container(color: Theme.of(context).dividerColor.withOpacity(0.3), height: separatorHeight),
          );
  }

  Widget _itemBuilder(context, index) {
    var item = items[index];
    if (item is ListedTextField) {
      return _textfieldBuilder(context, item);
    }
    return ListedItemWidget(
      item: item,
      rowInset: rowInset,
    );
  }

  Widget _textfieldBuilder(BuildContext context, ListedTextField item) {
    return Padding(
      padding: rowInset.copyWith(top: 0, bottom: 0),
      child: Row(
        children: [
          item.leadingIcon != null
              ? Row(
                  children: [
                    Icon(item.leadingIcon),
                    SizedBox(width: 16.0),
                  ],
                )
              : Container(),
          Expanded(
            child: TextFormField(
              textInputAction: item.isMultipleLine ? TextInputAction.newline : TextInputAction.done,
              //initialValue: item.initialValue,
              key: key,
              style: TextStyle(fontSize: 16),
              autocorrect: false,
              keyboardType: item.inputType,
              onChanged: item.onChanged,
              controller: item.controller,
              maxLines: item.isMultipleLine ? 25 : null,
              focusNode: FocusNode(),
              decoration: InputDecoration(
                  hintText: item.placeholder,
                  hintStyle: TextStyle(
                      fontSize: 16,
                      color:
                          ThemeNotifier.of(context).isDarkMode() ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.3)),
                  //focusColor: focusColor,
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }
}

class ZimpleTextField extends StatelessWidget {
  final TextInputType? inputType;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? placeholder;

  const ZimpleTextField({Key? key, this.inputType, this.controller, this.onChanged, this.placeholder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: TextInputAction.done,
      //initialValue: item.initialValue,
      key: key,
      style: TextStyle(fontSize: 15),
      autocorrect: false,
      keyboardType: inputType,
      onChanged: onChanged,
      controller: controller,
      decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(fontSize: 15),
          //focusColor: focusColor,
          focusedBorder: InputBorder.none,
          border: InputBorder.none),
    );
  }
}