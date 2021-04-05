// import 'package:flutter/material.dart';
// import 'package:frideos_core/frideos_core.dart';

// class InheritedStreamedDataProvider extends InheritedWidget {
//   final StreamedValue<DateTime> data;

//   InheritedStreamedDataProvider({
//     Widget child,
//     this.data,
//   }) : super(child: child);

//   @override
//   bool updateShouldNotify(InheritedStreamedDataProvider oldWidget) =>
//       data.value != oldWidget.data.value;

//   static InheritedStreamedDataProvider of(BuildContext context) => context
//       .dependOnInheritedWidgetOfExactType<InheritedStreamedDataProvider>();
// }
