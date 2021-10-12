import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/app_bar_widget.dart';
import 'package:zimple/model/work_category.dart';

class WorkCategorySelectScreen extends StatelessWidget {
  final Function(WorkCategory) onSelectWorkCategory;
  const WorkCategorySelectScreen({
    Key? key,
    required this.onSelectWorkCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(preferredSize: Size.fromHeight(60), child: StandardAppBar("Välj kategori")),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(workCategories.length, (index) {
                WorkCategory category = WorkCategory(index);
                return CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    this.onSelectWorkCategory(category);
                    Navigator.of(context).pop();
                  },
                  child: Column(
                    children: [
                      Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).shadowColor,
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: Offset(-2, 2), // changes position of shadow
                                )
                              ],
                              color: Theme.of(context).colorScheme.secondary),
                          child: Center(child: Icon(category.icon, color: Colors.white, size: 22))),
                      SizedBox(height: 8),
                      Text(category.name,
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold, fontSize: 14))
                    ],
                  ),
                );
              })),
        ));
  }
}
