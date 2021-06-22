import 'package:flutter/material.dart';

class CostTag {
  String name;
  IconData icon;
  CostTag({required this.name, required this.icon});
}

Map<String, CostTag> costTags = {
  "TAG_GASOLINE": CostTag(name: "Bensin", icon: Icons.local_gas_station),
  "TAG_PARKING": CostTag(name: "Parkering", icon: Icons.local_parking),
  "TAG_MATERIAL": CostTag(name: "Material", icon: Icons.local_parking),
};

class CostTagView extends StatelessWidget {
  const CostTagView({Key? key, required this.costTag}) : super(key: key);

  final CostTag costTag;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 15,
      backgroundColor: Colors.blue,
      child: Icon(costTag.icon),
    );
  }
}
