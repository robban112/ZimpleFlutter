import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';

class WorkCategory {
  final int id;
  late String name;
  late IconData icon;
  late Color color;
  WorkCategory(this.id) {
    this.name = workCategories[id]['name'];
    this.icon = workCategories[id]['icon'];
    this.color = workCategories[id]['color'];
  }
}

List<Map<String, dynamic>> workCategories = [
  {'name': 'Måla', 'icon': FontAwesome5.paint_brush, 'color': Colors.pink},
  {'name': 'Hantverk', 'icon': FontAwesome.hammer, 'color': Color.fromARGB(255, 19, 173, 119)},
  {'name': 'Flytt', 'icon': FontAwesome5.truck, 'color': Colors.black},
  {'name': 'Montering', 'icon': FontAwesome5.tools, 'color': Colors.orange},
  {'name': 'Möte', 'icon': Icons.groups, 'color': Colors.red},
  {'name': 'El', 'icon': FontAwesome5.bolt, 'color': Color(0xffFEC260)},
  {'name': 'Städ', 'icon': Icons.cleaning_services, 'color': Colors.blue},
  {'name': 'Service', 'icon': Icons.home_repair_service, 'color': Colors.purple},
];

Widget buildWorkCategoryBadge(WorkCategory? workCategory, {double size = 28, Color? color}) {
  if (workCategory == null) return Container();
  switch (workCategory.id) {
    case 0:
    case 1:
    case 3:
    case 4:
    case 5:
    case 6:
    case 7:
      return Container(child: Icon(workCategory.icon, size: size, color: color));
    case 2:
      return Container(child: Icon(workCategory.icon, size: size - 6, color: color));
    default:
      return Container();
  }
}
