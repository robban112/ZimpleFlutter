import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zimple/model/company_settings.dart';
import 'package:zimple/model/person.dart';
import 'package:zimple/screens/Calendar/calendar_screen.dart';
import 'package:zimple/utils/utils.dart';
import 'package:zimple/widgets/widgets.dart';

class DrawerWidget extends StatefulWidget {
  final Function(int) setNumberOfDays;
  final Function toggleTimeplanView;
  final Map<Person, bool> filteredPersons;
  final void Function(Person) didSetFilterForPersons;
  final List<Person> persons;
  final bool isPrivateEvents;
  DrawerWidget({
    required this.setNumberOfDays,
    required this.toggleTimeplanView,
    required this.filteredPersons,
    required this.didSetFilterForPersons,
    required this.persons,
    required this.isPrivateEvents,
  });

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  bool isFilteringPersonsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: buildListMenu(),
      ),
    );
  }

  Widget buildListMenu() {
    bool isDarkMode = Utils.isDarkMode(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: Center(
              child: Container(
                height: 30.0,
                child: SvgPicture.asset('images/zimpleLogo.svg', color: isDarkMode ? Colors.white : Colors.black),
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
          SizedBox(height: 12),
          _buildSetShouldShowWeekend(),
          SizedBox(height: 12),
          (!ManagerProvider.of(context).user.isAdmin && widget.isPrivateEvents) ? Container() : _buildFilterPersonsItem()
        ],
      ),
    );
  }

  Padding _buildSetShouldShowWeekend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text("Visa helg"),
        CupertinoSwitch(
          value: !CalendarSettings.watch(context).shouldSkipWeekends,
          onChanged: (val) {
            CalendarSettings.of(context).setShouldSkipWeekend(!val);
          },
        ),
      ]),
    );
  }

  Widget _buildFilterPersonsItem() {
    bool isAdmin = ManagerProvider.of(context).user.isAdmin;
    if (!isAdmin && CompanySettings.of(context).isPrivateEvents) return Container();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ExpansionPanelList(
        dividerColor: Colors.transparent,
        expansionCallback: (temp, _) {
          this.setState(() => this.isFilteringPersonsExpanded = !this.isFilteringPersonsExpanded);
        },
        elevation: 0,
        children: [
          ExpansionPanel(
              backgroundColor: Theme.of(context).colorScheme.background,
              canTapOnHeader: true,
              isExpanded: this.isFilteringPersonsExpanded,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Container(
                  color: Colors.transparent,
                  height: 12,
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
                      return GestureDetector(
                        onTap: () => widget.didSetFilterForPersons(person),
                        child: Padding(
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
                                      child: Text(person.name, overflow: TextOverflow.clip),
                                    ),
                                  )
                                ],
                              ),
                              Checkbox(
                                  activeColor: Theme.of(context).colorScheme.secondary,
                                  value: widget.filteredPersons[person],
                                  onChanged: (val) {
                                    widget.didSetFilterForPersons(person);
                                  })
                            ],
                          ),
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
