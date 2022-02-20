import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/listed_view/listed_switch.dart';

class ListedItem {
  final Widget? child;
  final String? text;
  final TextStyle? textStyle;
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
    this.textStyle,
  });
}

class ListedItemWidget extends StatelessWidget {
  const ListedItemWidget({
    Key? key,
    required this.item,
    this.rowInset = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  }) : super(key: key);

  final ListedItem item;
  final EdgeInsets rowInset;

  @override
  Widget build(BuildContext context) {
    return _inkWell(
      isTappable: item.onTap != null,
      child: Padding(
        padding: this.rowInset,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _leading(),
              item.text != null ? Text(item.text!, style: item.textStyle ?? TextStyle(fontSize: 16)) : item.child!,
            ],
          ),
          Expanded(child: Container()),
          item.trailingWidget != null ? item.trailingWidget! : Icon(Icons.chevron_right)
        ]),
      ),
    );
  }

  Widget _inkWell({required Widget child, required bool isTappable}) {
    if (isTappable)
      return Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.grey.shade300,
          onTap: () {
            if (item.onTap != null) item.onTap!();
          },
          child: child,
        ),
      );
    return child;
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
        child: Text(text, style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 0.5)));
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
    } else if (item is ListedSwitch) {
      return _buildListedSwitch(context, item);
    }
    return ListedItemWidget(
      item: item,
      rowInset: rowInset,
    );
  }

  Widget _buildListedSwitch(BuildContext context, ListedSwitch item) {
    return ListedItemWidget(
      item: ListedItem(
        text: item.text,
        leadingIcon: item.leadingIcon,
        //textStyle: _hintStyle(context),
        trailingWidget: SizedBox(
          height: 32,
          width: 32,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CupertinoSwitch(
              onChanged: item.onChanged,
              value: item.initialValue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(ListedItem item) {
    return item.leadingIcon != null
        ? Row(
            children: [
              Icon(item.leadingIcon),
              SizedBox(width: 16.0),
            ],
          )
        : Container();
  }

  Widget _textfieldBuilder(BuildContext context, ListedTextField item) {
    return _multilineTextfield(
      context,
      item,
      child: Padding(
        padding: rowInset.copyWith(top: 0, bottom: 0),
        child: Row(
          children: [
            _buildLeadingIcon(item),
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
                    hintStyle: hintStyle(context),
                    //focusColor: focusColor,
                    focusedBorder: InputBorder.none,
                    border: InputBorder.none),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _multilineTextfield(BuildContext context, ListedTextField item, {required Widget child}) {
    if (item.isMultipleLine) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              child,
            ],
          ),
        ),
      );
    } else
      return child;
  }

  static TextStyle hintStyle(BuildContext context) {
    return TextStyle(
        fontSize: 16,
        color: ThemeNotifier.of(context).isDarkMode() ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.3));
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
