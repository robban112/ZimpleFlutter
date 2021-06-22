import 'package:flutter/material.dart';

class ListedItem {
  final Widget child;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Widget? trailingWidget;
  final VoidCallback? onTap;
  ListedItem(
      {required this.child,
      this.leadingIcon,
      this.trailingIcon,
      this.onTap,
      this.trailingWidget});
}

// class ZimpleTextField extends StatelessWidget {
//   final String? placeholder;
//   final Function(String)? onChanged;
//   final GlobalKey<FormState>? key;
//   final String? initialValue;
//   final TextEditingController? controller;
//   final TextInputType? inputType;
//   const ZimpleTextField(
//       {this.key,
//       leadingIcon,
//       this.placeholder,
//       this.onChanged,
//       this.initialValue = "",
//       this.controller,
//       this.inputType = TextInputType.text});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: TextFormField(
//             textInputAction: TextInputAction.done,
//             initialValue: initialValue,
//             key: key,
//             style: TextStyle(fontSize: 17),
//             autocorrect: false,
//             keyboardType: inputType,
//             onChanged: onChanged,
//             controller: controller,
//             decoration: InputDecoration(
//               hintText: placeholder,
//               hintStyle: TextStyle(fontSize: 17),
//               //focusColor: focusColor,
//               focusedBorder: InputBorder.none,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

class ListedTitle extends StatelessWidget {
  const ListedTitle({Key? key, required this.text}) : super(key: key);

  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
        child: Text(text,
            style: TextStyle(
                color: Colors.grey.shade700, fontWeight: FontWeight.w500)));
  }
}

class ListedTextField extends ListedItem {
  final String? placeholder;
  final Function(String)? onChanged;
  final GlobalKey<FormState>? key;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType? inputType;
  ListedTextField(
      {this.key,
      leadingIcon,
      this.placeholder,
      this.onChanged,
      this.initialValue = "",
      this.controller,
      this.inputType = TextInputType.text})
      : super(leadingIcon: leadingIcon, child: Container());
}

class ListedView extends StatelessWidget {
  final List<ListedItem> items;
  final EdgeInsets rowInset;
  final bool isScrollable;
  final bool hidesSeparatorByDefault;
  final bool hidesFirstLastSeparator;
  final double separatorHeight;
  ListedView(
      {required this.items,
      this.rowInset =
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      this.isScrollable = false,
      this.hidesSeparatorByDefault = false,
      this.separatorHeight = 1,
      this.hidesFirstLastSeparator = true});
  final Color separatorColor = Colors.grey.shade300;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          hidesFirstLastSeparator
              ? Container()
              : Container(height: separatorHeight, color: separatorColor),
          ListView.separated(
            shrinkWrap: true,
            physics: isScrollable
                ? AlwaysScrollableScrollPhysics()
                : NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: _itemBuilder,
            separatorBuilder: _separatorBuilder,
          ),
          hidesFirstLastSeparator
              ? Container()
              : Container(height: separatorHeight, color: separatorColor),
        ],
      ),
    );
  }

  Widget _separatorBuilder(contex, index) {
    ListedItem item = items[index];
    double leftInset =
        item.leadingIcon != null ? rowInset.left + 42 : rowInset.left;
    return hidesSeparatorByDefault
        ? Container()
        : Padding(
            padding:
                rowInset.copyWith(top: 0, bottom: 0, left: leftInset, right: 0),
            child: Container(color: separatorColor, height: separatorHeight),
          );
  }

  Widget _itemBuilder(contex, index) {
    var item = items[index];
    if (item is ListedTextField) {
      return _textfieldBuilder(item);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        splashColor: Colors.grey.shade300,
        child: Padding(
          padding: this.rowInset,
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                item.leadingIcon != null
                    ? Row(
                        children: [
                          Icon(item.leadingIcon,
                              color: Colors.black.withAlpha(190)),
                          SizedBox(width: 16.0),
                        ],
                      )
                    : Container(),
                item.child
              ],
            ),
            Expanded(child: Container()),
            item.trailingWidget != null
                ? item.trailingWidget!
                : Icon(item.trailingIcon)
          ]),
        ),
      ),
    );
  }

  Widget _textfieldBuilder(ListedTextField item) {
    return Padding(
      padding: rowInset.copyWith(top: 0, bottom: 0),
      child: Row(
        children: [
          item.leadingIcon != null
              ? Row(
                  children: [
                    Icon(item.leadingIcon, color: Colors.black.withAlpha(190)),
                    SizedBox(width: 16.0),
                  ],
                )
              : Container(),
          Expanded(
            child: TextFormField(
              textInputAction: TextInputAction.done,
              //initialValue: item.initialValue,
              key: key,
              style: TextStyle(fontSize: 15),
              autocorrect: false,
              keyboardType: item.inputType,
              onChanged: item.onChanged,
              controller: item.controller,
              decoration: InputDecoration(
                  hintText: item.placeholder,
                  hintStyle: TextStyle(fontSize: 15),
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

  const ZimpleTextField(
      {Key? key,
      this.inputType,
      this.controller,
      this.onChanged,
      this.placeholder})
      : super(key: key);

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
