import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';

class WorkCategory {
  final int id;
  late String name;
  late IconData icon;
  WorkCategory(this.id) {
    this.name = workCategories[id]['name'];
    this.icon = workCategories[id]['icon'];
  }
}

List<Map<String, dynamic>> workCategories = [
  {'name': 'Måla', 'icon': FontAwesome5.paint_brush},
  {'name': 'Hantverk', 'icon': Icons.carpenter},
  {'name': 'Flytt', 'icon': FontAwesome5.truck},
  {'name': 'Montering', 'icon': FontAwesome5.tools},
];
