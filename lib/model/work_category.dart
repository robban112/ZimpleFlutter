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
  {'name': 'Hantverk', 'icon': FontAwesome.hammer},
  {'name': 'Flytt', 'icon': FontAwesome5.truck},
  {'name': 'Montering', 'icon': FontAwesome5.tools},
  {'name': 'Möte', 'icon': Icons.groups},
  {'name': 'El', 'icon': FontAwesome5.bolt},
  {'name': 'Städ', 'icon': Icons.cleaning_services},
  {'name': 'Service', 'icon': Icons.home_repair_service},
];
