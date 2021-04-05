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
    assert(result != null, 'No FrogColor found in context');
    return result;
  }

  @override
  bool updateShouldNotify(ProviderWidget old) => key != old.key;
}
