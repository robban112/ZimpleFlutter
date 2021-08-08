import 'package:flutter/material.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/utils/constants.dart';
import 'package:zimple/widgets/person_circle_avatar.dart';
import 'package:zimple/widgets/listed_view.dart';

class DrawerWidget extends StatefulWidget {
  final Function(int) setNumberOfDays;
  final Function toggleTimeplanView;
  final Map<Person, bool> filteredPersons;
  final void Function(Person) didSetFilterForPersons;
  final List<Person> persons;
  DrawerWidget(
      {required this.setNumberOfDays,
      required this.toggleTimeplanView,
      required this.filteredPersons,
      required this.didSetFilterForPersons,
      required this.persons});

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  bool isFilteringPersonsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).backgroundColor,
        child: buildListMenu(),
      ),
    );
  }

  Widget buildListMenu() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: Center(
              child: Container(
                height: 30.0,
                child: Image.asset('images/zimple_logo_black.png'),
              ),
            ),
          ),
          ListedView(
            hidesSeparatorByDefault: true,
            items: [
              ListedItem(
                  leadingIcon: Icons.view_agenda,
                  trailingIcon: Icons.chevron_right,
                  child: Text("Tidsplan"),
                  onTap: () {
                    this.widget.toggleTimeplanView();
                  }),
              ListedItem(
                  leadingIcon: Icons.view_day,
                  trailingIcon: Icons.chevron_right,
                  child: Text("Dag"),
                  onTap: () {
                    this.widget.setNumberOfDays(1);
                  }),
              ListedItem(
                  leadingIcon: Icons.view_column,
                  trailingIcon: Icons.chevron_right,
                  child: Text("3 dagar"),
                  onTap: () {
                    this.widget.setNumberOfDays(3);
                  }),
              ListedItem(
                  leadingIcon: Icons.view_column,
                  trailingIcon: Icons.chevron_right,
                  child: Text("Vecka"),
                  onTap: () {
                    this.widget.setNumberOfDays(7);
                  }),
            ],
          ),
          SizedBox(height: 30),
          _buildFilterPersonsItem()
        ],
      ),
    );
  }

  Padding _buildFilterPersonsItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ExpansionPanelList(
        dividerColor: Colors.transparent,
        expansionCallback: (temp, _) {
          this.setState(() => this.isFilteringPersonsExpanded =
              !this.isFilteringPersonsExpanded);
        },
        elevation: 0,
        children: [
          ExpansionPanel(
              backgroundColor: Theme.of(context).backgroundColor,
              canTapOnHeader: true,
              isExpanded: this.isFilteringPersonsExpanded,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Container(
                  color: Colors.transparent,
                  height: 50,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Filtrera personer",
                    ),
                  ),
                );
              },
              body: Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.persons.length,
                    itemBuilder: (context, index) {
                      var person = widget.persons[index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                PersonCircleAvatar(person: person),
                                SizedBox(width: 12.0),
                                SizedBox(
                                  width: 100,
                                  child: ClipRRect(
                                    child: Text(person.name,
                                        overflow: TextOverflow.clip),
                                  ),
                                )
                              ],
                            ),
                            Checkbox(
                                value: widget.filteredPersons[person],
                                onChanged: (val) {
                                  widget.didSetFilterForPersons(person);
                                })
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, _) => SizedBox(height: 0.0),
                  ),
                  SizedBox(height: 75)
                ],
              )),
        ],
      ),
    );
  }
}
