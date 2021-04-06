import 'package:flutter/material.dart';
import 'package:zimple/model/event.dart';

class ProviderWidget extends InheritedWidget {
  const ProviderWidget(
      {@required this.drawerKey,
      @required this.child,
      @required this.didTapEvent});
  final GlobalKey<ScaffoldState> drawerKey;
  final Function(Event) didTapEvent;
  final Widget child;

  static ProviderWidget of(BuildContext context) {
    final ProviderWidget result =
        context.dependOnInheritedWidgetOfExactType<ProviderWidget>();
    assert(result != null, '');
    return result;
  }

  @override
  bool updateShouldNotify(ProviderWidget old) => key != old.key;
}
