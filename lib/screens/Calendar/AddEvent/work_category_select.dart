import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zimple/model/work_category.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/utils/theme_manager.dart';
import 'package:zimple/widgets/app_bar_widget.dart';

class WorkCategorySelectScreen extends StatelessWidget {
  final Function(WorkCategory) onSelectWorkCategory;
  const WorkCategorySelectScreen({
    Key? key,
    required this.onSelectWorkCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(preferredSize: appBarSize, child: StandardAppBar("Välj kategori")),
        body: Padding(padding: const EdgeInsets.all(12.0), child: _body(context)
            // Wrap(
            //     spacing: 12,
            //     runSpacing: 12,
            //     children: List.generate(workCategories.length, (index) {
            //       WorkCategory category = WorkCategory(index);
            //       return CupertinoButton(
            //         padding: EdgeInsets.zero,
            //         onPressed: () {

            //         },
            //         child: Column(
            //           children: [
            //             Container(
            //                 height: 56,
            //                 width: 56,
            //                 decoration: BoxDecoration(
            //                     shape: BoxShape.circle,
            //                     boxShadow: [
            //                       BoxShadow(
            //                         color: Theme.of(context).shadowColor,
            //                         spreadRadius: 1,
            //                         blurRadius: 3,
            //                         offset: Offset(-2, 2), // changes position of shadow
            //                       )
            //                     ],
            //                     color: Theme.of(context).colorScheme.secondary),
            //                 child: Center(child: Icon(category.icon, color: Colors.white, size: 22))),
            //             SizedBox(height: 8),
            //             Text(category.name,
            //                 style: Theme.of(context).textTheme.bodyText1?.copyWith(fontWeight: FontWeight.bold, fontSize: 14))
            //           ],
            //         ),
            //       );
            //     })),
            ));
  }

  void _onSelectWorkCategory(BuildContext context, WorkCategory workCategory) {
    this.onSelectWorkCategory(workCategory);
    Navigator.of(context).pop();
  }

  Widget _body(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        WorkCategory workCategory = WorkCategory(index);
        return CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _onSelectWorkCategory(context, workCategory),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color: workCategory.color,
                        shape: BoxShape.circle,
                      ),
                      child: buildWorkCategoryBadge(workCategory, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(workCategory.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeNotifier.of(context).textColor,
                        )),
                  ],
                ),
                Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color),
              ],
            ),
          ),
        );
      },
      itemCount: workCategories.length,
    );
  }
}
